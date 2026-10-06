import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/auth_groups_api.dart';
import 'package:nexo_offline_poc/auth_groups_page.dart';
import 'package:nexo_offline_poc/main.dart';

class _FakeApi extends AuthGroupsApi {
  _FakeApi() : super('http://127.0.0.1');

  final Map<String, List<NexoGroup>> groups = {};
  final keys = <String>[];
  final payloads = <String>[];
  String? email;
  var failNextMode = false;
  var failLogin = false;
  var failLogout = false;
  var nextId = 0;
  Completer<void>? registerGate;
  Completer<void>? logoutGate;
  Completer<void>? createGroupGate;
  Completer<void>? listGroupsGate;

  @override
  bool get hasSession => email != null;

  @override
  Future<Map<String, dynamic>> register(String email, String password) async {
    await registerGate?.future;
    this.email = email;
    return {'user': {'id': 'user-${email.hashCode}', 'email': email}, 'token': 'synthetic'};
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (failLogin) throw const AuthGroupsException(401, 'Credenciales inválidas.');
    this.email = email;
    return {'user': {'id': 'user-${email.hashCode}', 'email': email}, 'token': 'synthetic'};
  }

  @override
  Future<void> logout() async {
    await logoutGate?.future;
    if (failLogout) throw const AuthGroupsException(503, 'No disponible.', temporary: true);
    email = null;
  }

  @override
  void discardSession() => email = null;

  @override
  Future<List<NexoGroup>> listGroups() async {
    await listGroupsGate?.future;
    return List.unmodifiable(groups[email] ?? const []);
  }

  @override
  Future<NexoGroup> createGroup(String name, String type) async {
    await createGroupGate?.future;
    final group = NexoGroup(id: 'group-${++nextId}', name: name, type: type, revision: '0', canChangeMode: true);
    groups.putIfAbsent(email!, () => []).add(group);
    return group;
  }

  @override
  Future<Map<String, dynamic>> changeMode({
    required String groupId,
    required String destination,
    required String expectedRevision,
    required String idempotencyKey,
  }) async {
    keys.add(idempotencyKey);
    payloads.add('$groupId|$destination|$expectedRevision');
    if (failNextMode) {
      failNextMode = false;
      throw const AuthGroupsException(503, 'API temporalmente no disponible.', temporary: true);
    }
    final owned = groups[email!]!;
    final index = owned.indexWhere((group) => group.id == groupId);
    final old = owned[index];
    owned[index] = NexoGroup(id: old.id, name: old.name, type: destination, revision: '1', canChangeMode: true);
    return {'ok': true};
  }

  @override
  void close() {}
}

Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

Future<ThemeData> _nexoTheme(WidgetTester tester) async {
  await tester.pumpWidget(NexoPocApp(
    supportDirectoryProvider: () async => throw const FileSystemException('Sin almacenamiento'),
  ));
  return tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('registro, grupos, replay estable, salida y cambio de usuario', (tester) async {
    final api = _FakeApi()..failNextMode = true;
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await _flush(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _flush(tester);
    expect(find.text('Tus grupos'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Nombre del grupo'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del grupo'), 'Casa de prueba');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear grupo'));
    await _flush(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Crear grupo'));
    await _flush(tester);
    expect(api.groups.values.expand((items) => items), isNotEmpty);
    expect(find.text('Tus grupos'), findsOneWidget);
    expect(find.text('Aún no tienes grupos.'), findsNothing);
    await tester.ensureVisible(find.text('Tus grupos'));
    await _flush(tester);
    expect(find.text('Casa de prueba'), findsOneWidget);
    await tester.ensureVisible(find.text('Cambiar a Familia'));
    await _flush(tester);
    await tester.tap(find.text('Cambiar a Familia'));
    await _flush(tester);
    expect(find.text('Confirmar cambio de modo'), findsOneWidget);
    await tester.tap(find.text('Confirmar'));
    await _flush(tester);
    expect(api.keys, hasLength(1));
    expect(find.textContaining('temporalmente no disponible'), findsOneWidget);
    await tester.ensureVisible(find.text('Reintentar el mismo cambio'));
    await _flush(tester);
    await tester.tap(find.text('Reintentar el mismo cambio'));
    await _flush(tester);
    expect(api.keys, hasLength(2));
    expect(api.keys.first, api.keys.last);
    expect(api.payloads.first, api.payloads.last);
    expect(find.text('API temporalmente no disponible.'), findsNothing);
    expect(find.text('Familia · revisión 1'), findsOneWidget);

    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await _flush(tester);
    expect(find.text('Tus grupos'), findsNothing);
    expect(find.text('Casa de prueba'), findsNothing);
    await tester.tap(find.text('Ya tengo una cuenta'));
    await _flush(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'dos@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await _flush(tester);
    expect(find.text('Tus grupos'), findsOneWidget);
    expect(find.text('Casa de prueba'), findsNothing);
  });

  testWidgets('expone error de login y no afirma revocación remota fallida', (tester) async {
    final api = _FakeApi()..failLogin = true;
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await _flush(tester);
    await tester.tap(find.text('Ya tengo una cuenta'));
    await _flush(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await _flush(tester);
    expect(find.text('Credenciales inválidas.'), findsAtLeastNWidgets(1));
    api.failLogin = false;
    await tester.tap(find.text('Crear una cuenta'));
    await _flush(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _flush(tester);
    api.failLogout = true;
    await tester.tap(find.text('Cerrar sesión'));
    await _flush(tester);
    expect(find.textContaining('No se confirmó el cierre remoto'), findsOneWidget);
  });

  testWidgets('no accede a formularios descartados cuando registro termina tarde', (tester) async {
    final api = _FakeApi()..registerGate = Completer<void>();
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    api.registerGate!.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no accede al formulario descartado cuando crear grupo termina tarde', (tester) async {
    final api = _FakeApi();
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _flush(tester);
    api.createGroupGate = Completer<void>();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del grupo'), 'Casa de prueba');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear grupo'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    api.createGroupGate!.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('no accede al formulario descartado cuando logout termina tarde', (tester) async {
    final api = _FakeApi();
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _flush(tester);
    api.logoutGate = Completer<void>();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    api.logoutGate!.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('bloquea cambio de sesión mientras se actualizan los grupos', (tester) async {
    final api = _FakeApi();
    final theme = await _nexoTheme(tester);
    await tester.pumpWidget(MaterialApp(theme: theme, home: AuthGroupsPage(apiBaseUrl: 'http://127.0.0.1', api: api)));
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'uno@example.test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await _flush(tester);
    api.listGroupsGate = Completer<void>();
    await tester.tap(find.byTooltip('Actualizar grupos'));
    await tester.pump();
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Cerrar sesión')).onPressed, isNull);
    api.listGroupsGate!.complete();
    await _flush(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mantiene etiquetas y objetivos accesibles a escala 100% y 200%', (tester) async {
    final api = _FakeApi();
    final theme = await _nexoTheme(tester);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final scale in [1.0, 2.0]) {
      api.groups['a11y@example.test'] = [
        const NexoGroup(id: 'a11y-group', name: 'Grupo accesible', type: 'PAREJA', revision: '0', canChangeMode: true),
      ];
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: AuthGroupsPage(key: ValueKey(scale), apiBaseUrl: 'http://127.0.0.1', api: api),
      ));
      await _flush(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'a11y@example.test');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), 'Clave sintética 123!');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Crear cuenta'));
      await _flush(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
      await _flush(tester);
      final semantics = tester.ensureSemantics();
      try {
        for (final guideline in [
          textContrastGuideline,
          labeledTapTargetGuideline,
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(guideline));
        }
      } finally {
        semantics.dispose();
      }
    }
  });

  testWidgets('AppBar conserva privacidad y ofrece el acceso a grupos', (tester) async {
    await tester.pumpWidget(NexoPocApp(
      supportDirectoryProvider: () async => throw const FileSystemException('Sin almacenamiento'),
    ));
    expect(find.byTooltip('Privacidad y uso'), findsOneWidget);
    expect(find.byTooltip('Grupos'), findsOneWidget);
  });
}
