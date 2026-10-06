import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexo_offline_poc/auth_groups_api.dart';
import 'package:nexo_offline_poc/main.dart';

Future<int> _reservePort() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;
  await server.close();
  return port;
}

Future<Process> _startApi(String workingDirectory, int port) async {
  final process = await Process.start(
    Platform.environment['NEXO_NODE_PATH'] ?? 'node',
    ['dist/src/main.js'],
    workingDirectory: workingDirectory,
    environment: {...Platform.environment, 'PORT': '$port'},
  );
  process.stdout.listen((_) {});
  process.stderr.listen((_) {});
  var exited = false;
  process.exitCode.then((_) => exited = true);
  final client = HttpClient();
  try {
    for (var attempt = 0; attempt < 100; attempt++) {
      if (exited) throw StateError('La API finalizó al iniciar.');
      try {
        final request = await client.getUrl(Uri.parse('http://127.0.0.1:$port/accounts/no-existe'));
        if ((await request.close()).statusCode == 404) return process;
      } on SocketException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    throw StateError('La API no respondió en 10 segundos.');
  } finally {
    client.close(force: true);
  }
}

Future<void> _stopApi(Process? process) async {
  if (process == null) return;
  process.kill();
  try {
    await process.exitCode.timeout(const Duration(seconds: 5));
  } on TimeoutException {
    process.kill(ProcessSignal.sigkill);
  }
}

Future<void> _pump(WidgetTester tester) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(LinearProgressIndicator).evaluate().isEmpty) return;
  }
  throw StateError('La operación visual no terminó en 8 segundos.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dataDirectory;
  late String apiUrl;
  late String apiWorkingDirectory;
  var email = '';
  var parejaName = '';
  var familiaName = '';
  const password = 'Clave sintética de integración 123!';
  Process? apiProcess;

  Future<void> cleanup() async {
    if (email.isEmpty) return;
    const script = '''
const { PrismaService } = require('./dist/src/database/prisma.service.js');
(async () => {
  const db = new PrismaService();
  await db.onModuleInit();
  try {
    await db.group.deleteMany({ where: { name: { in: process.argv.slice(1) } } });
    await db.user.deleteMany({ where: { email: process.env.NEXO_FIXTURE_EMAIL } });
  } finally { await db.onModuleDestroy(); }
})().catch(() => process.exit(1));
''';
    final result = await Process.run(
      Platform.environment['NEXO_NODE_PATH'] ?? 'node',
      ['-e', script, parejaName, familiaName],
      workingDirectory: apiWorkingDirectory,
      environment: {...Platform.environment, 'NEXO_FIXTURE_EMAIL': email},
    );
    if (result.exitCode != 0) throw StateError('No se pudieron limpiar fixtures de grupos.');
  }

  setUp(() async {
    if (Platform.environment['DATABASE_URL'] == null) {
      throw StateError('La integración requiere DATABASE_URL y PostgreSQL real.');
    }
    dataDirectory = await Directory.systemTemp.createTemp('nexo-auth-groups-');
    apiWorkingDirectory = Platform.environment['NEXO_API_WORKDIR'] ??
        Directory.current.parent.uri.resolve('api/').toFilePath();
    final port = await _reservePort();
    apiUrl = 'http://127.0.0.1:$port';
    final tag = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    email = 'ui-$tag@example.test';
    parejaName = 'PoC $tag pareja';
    familiaName = 'PoC $tag familia';
    apiProcess = await _startApi(apiWorkingDirectory, port);
  });

  tearDown(() async {
    await _stopApi(apiProcess);
    apiProcess = null;
    await cleanup();
    await dataDirectory.delete(recursive: true);
  });

  testWidgets('sesión HTTP, crea ambos grupos, migra bilateralmente y consulta antes de salir', (tester) async {
    await tester.pumpWidget(NexoPocApp(
      apiBaseUrl: apiUrl,
      supportDirectoryProvider: () async => dataDirectory,
    ));
    for (var attempt = 0; attempt < 80; attempt++) {
      if (find.byTooltip('Grupos').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byTooltip('Grupos'));
    await _pump(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), email);
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), password);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _pump(tester);
    if (find.text('Tus grupos').evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
      await tester.pump();
    }
    expect(find.text('Tus grupos'), findsOneWidget,
        reason: tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).join(' | '));

    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Nombre del grupo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del grupo'), parejaName);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear grupo'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear grupo'));
    await _pump(tester);
    expect(find.text(parejaName), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Nombre del grupo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del grupo'), familiaName);
    await tester.tap(find.text('Familia'));
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear grupo'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Crear grupo'));
    await _pump(tester);
    if (find.text(familiaName).evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
      await tester.pump();
    }
    expect(find.text(familiaName), findsOneWidget,
        reason: tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).join(' | '));

    final sessionApi = AuthGroupsApi(apiUrl);
    final groups = await tester.runAsync(() async {
      await sessionApi.login(email, password);
      final initial = await sessionApi.listGroups();
      final pareja = initial.singleWhere((group) => group.name == parejaName);
      final familia = initial.singleWhere((group) => group.name == familiaName);
      expect(pareja.type, 'PAREJA');
      expect(familia.type, 'FAMILIA');
      return initial;
    });
    sessionApi.close();
    expect(groups, hasLength(2));

    final parejaEntry = find.ancestor(of: find.text(parejaName), matching: find.byType(Column)).first;
    final familiaEntry = find.ancestor(of: find.text(familiaName), matching: find.byType(Column)).first;
    final toFamily = find.descendant(of: parejaEntry, matching: find.text('Cambiar a Familia'));
    await tester.ensureVisible(toFamily);
    await tester.pumpAndSettle();
    await tester.tap(toFamily);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await _pump(tester);
    for (var attempt = 0; attempt < 80 && find.text('Familia · revisión 1').evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Familia · revisión 1'), findsOneWidget);
    final toCouple = find.descendant(of: parejaEntry, matching: find.text('Cambiar a Pareja'));
    await tester.ensureVisible(toCouple);
    await tester.pumpAndSettle();
    await tester.tap(toCouple);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await _pump(tester);
    for (var attempt = 0; attempt < 80 && find.text('Pareja · revisión 2').evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Pareja · revisión 2'), findsOneWidget);
    expect(find.descendant(of: familiaEntry, matching: find.text('Familia · revisión 0')), findsOneWidget);

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    for (var attempt = 0; attempt < 40 && find.widgetWithText(FilledButton, 'Crear cuenta').evaluate().isEmpty; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.widgetWithText(FilledButton, 'Crear cuenta'), findsOneWidget);
  });
}
