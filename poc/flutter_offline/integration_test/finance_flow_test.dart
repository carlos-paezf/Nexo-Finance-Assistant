import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nexo_offline_poc/main.dart';

Future<void> _waitForApi(String url) async {
  final client = HttpClient();
  try {
    for (var attempt = 0; attempt < 100; attempt++) {
      try {
        final request = await client.getUrl(Uri.parse('$url/accounts/no-existe'));
        final response = await request.close();
        if (response.statusCode == HttpStatus.notFound) return;
      } on SocketException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    throw StateError('La API no respondió en 10 segundos.');
  } finally {
    client.close(force: true);
  }
}

Future<void> _expectApiDown(String url) async {
  final client = HttpClient()..connectionTimeout = const Duration(milliseconds: 500);
  try {
    final request = await client.getUrl(Uri.parse('$url/accounts/no-existe'));
    await request.close();
    throw StateError('El API debía estar detenido para la fase offline.');
  } on SocketException {
    // The app starts with an intentionally unavailable API.
  } finally {
    client.close(force: true);
  }
}

Future<Process> _startApi(String workingDirectory) async {
  final process = await Process.start(
    Platform.environment['NEXO_NODE_PATH'] ?? 'node',
    ['dist/src/main.js'],
    workingDirectory: workingDirectory,
    environment: {'PORT': '3000'},
  );
  process.stdout.listen((_) {});
  process.stderr.listen((_) {});
  return process;
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

Future<void> _waitForLedgerLoaded(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (find.text('Crea una cuenta').evaluate().isNotEmpty ||
        find.text('Sincronización').evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw StateError('La pantalla financiera no terminó de cargar.');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory dataDirectory;
  const apiUrl = 'http://127.0.0.1:3000';
  const accountId = 'ui-t005-account';
  final apiWorkingDirectory = Platform.environment['NEXO_API_WORKDIR'] ??
      Directory.current.parent.uri.resolve('api/').toFilePath();
  Process? apiProcess;

  Future<void> cleanupAccount() async {
    final result = await Process.run(
      Platform.environment['NEXO_NODE_PATH'] ?? 'node',
      ['dist/test/cleanup-account.js', accountId],
      workingDirectory: apiWorkingDirectory,
    );
    if (result.exitCode != 0) {
      throw StateError('No se pudo limpiar la cuenta sintética de integración.');
    }
  }

  setUp(() async {
    dataDirectory = await Directory.systemTemp.createTemp('nexo-flow-');
    await _expectApiDown(apiUrl);
    await cleanupAccount();
  });

  tearDown(() async {
    await _stopApi(apiProcess);
    apiProcess = null;
    await cleanupAccount();
    await dataDirectory.delete(recursive: true);
  });

  testWidgets('crea cuenta, opera offline, reabre y sincroniza con API real', (tester) async {
    final ids = [accountId, 'ui-t005-income', 'ui-t005-expense'];
    Future<void> openApp() async {
      await tester.pumpWidget(NexoPocApp(
        key: UniqueKey(),
        apiBaseUrl: apiUrl,
        supportDirectoryProvider: () async => dataDirectory,
        idProvider: () => ids.removeAt(0),
      ));
      await _waitForLedgerLoaded(tester);
      await tester.pumpAndSettle();
    }

    await openApp();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre de la cuenta'), 'PoC sintética');
    await tester.enterText(find.widgetWithText(TextFormField, 'Saldo inicial (COP)'), '1000,00');
    await tester.tap(find.text('Guardar cuenta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ingreso'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Ingreso PoC');
    await tester.enterText(find.widgetWithText(TextFormField, 'Importe (COP)'), '200,00');
    await tester.tap(find.text('Guardar ingreso'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gasto'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Descripción'), 'Gasto PoC');
    await tester.enterText(find.widgetWithText(TextFormField, 'Importe (COP)'), '12,34');
    await tester.tap(find.text('Guardar gasto'));
    await tester.pumpAndSettle();
    expect(find.text(r'$1.187,66'), findsOneWidget);

    await tester.tap(find.text('Sincronizar con API'));
    await tester.pumpAndSettle();
    expect(find.textContaining('con error'), findsOneWidget);
    expect(find.text(r'$1.187,66'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await openApp();
    expect(find.text('2 pendientes · 0 sincronizados · 1 con error'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ingreso PoC'), 300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ingreso PoC'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Gasto PoC'), 300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gasto PoC'), findsOneWidget);

    apiProcess = await _startApi(apiWorkingDirectory);
    await _waitForApi(apiUrl);
    await tester.scrollUntilVisible(
      find.text('Sincronizar con API'), 300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Sincronizar con API'));
    await tester.pumpAndSettle();
    expect(find.text('0 pendientes · 3 sincronizados · 0 con error'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text(r'Saldo confirmado por API: $1.187,66'), findsOneWidget);
  });
}
