import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/main.dart';
import 'package:nexo_offline_poc/privacy_use_page.dart';

void main() {
  testWidgets('la información se abre sin cuenta ni almacenamiento disponible',
      (tester) async {
    await tester.pumpWidget(NexoPocApp(
      supportDirectoryProvider: () async =>
          throw const FileSystemException('Almacenamiento no disponible'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Privacidad y uso'));
    await tester.pumpAndSettle();
    expect(find.text('Información de la PoC'), findsOneWidget);

    await tester.tap(find.text('Política de privacidad y datos personales'));
    await tester.pumpAndSettle();
    expect(find.textContaining('El archivo local no está cifrado'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PrivacyUsePage), findsNothing);
  });

  testWidgets('texto al 200% en 360 px permite leer y abrir licencias',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: const PrivacyUsePage(),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Requisitos de accesibilidad'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Requisitos de accesibilidad'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Licencias de componentes'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await tester.tap(find.text('Licencias de componentes'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
