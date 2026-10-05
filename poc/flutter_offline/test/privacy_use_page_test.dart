import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('teclado permite navegar, expandir y abrir licencias',
      (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<bool> key(LogicalKeyboardKey value, {bool shift = false}) async {
      if (shift) {
        await tester.sendKeyDownEvent(
          LogicalKeyboardKey.shiftLeft,
          platform: 'windows',
        );
      }
      final handled = await tester.sendKeyEvent(value, platform: 'windows');
      if (shift) {
        await tester.sendKeyUpEvent(
          LogicalKeyboardKey.shiftLeft,
          platform: 'windows',
        );
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      return handled;
    }

    void expectFocusedAndVisible(Finder finder) {
      final focusedContext = FocusManager.instance.primaryFocus?.context;
      expect(focusedContext, isNotNull);
      final focusBox = focusedContext!.findRenderObject()! as RenderBox;
      final focusRect = focusBox.localToGlobal(Offset.zero) & focusBox.size;
      final rect = tester.getRect(finder);
      expect(focusRect.center, rect.center);
      expect(focusRect.width, lessThanOrEqualTo(rect.width + 16));
      expect(focusRect.height, lessThanOrEqualTo(rect.height + 16));
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      final viewport = Offset.zero & size;
      expect(viewport.contains(rect.topLeft), isTrue);
      expect(rect.right, lessThanOrEqualTo(viewport.right));
      expect(viewport.contains(rect.center), isTrue);
      expect(rect.bottom, lessThanOrEqualTo(viewport.bottom + 4));
    }

    Offset focusCenter() {
      final box = FocusManager.instance.primaryFocus!.context!
          .findRenderObject()! as RenderBox;
      return box.localToGlobal(box.size.center(Offset.zero));
    }

    await tester.pumpWidget(NexoPocApp(
      supportDirectoryProvider: () async =>
          throw const FileSystemException('Almacenamiento no disponible'),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final privacyButton = find.ancestor(
      of: find.byTooltip('Privacidad y uso'),
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(privacyButton).onPressed, isNotNull);
    await key(LogicalKeyboardKey.tab);
    expectFocusedAndVisible(privacyButton);
    expect(await key(LogicalKeyboardKey.enter), isTrue);
    expect(find.byType(PrivacyUsePage), findsOneWidget);

    final firstSection = find.ancestor(
      of: find.text('Política de privacidad y datos personales'),
      matching: find.byType(ExpansionTile),
    );
    await key(LogicalKeyboardKey.tab);
    await key(LogicalKeyboardKey.tab);
    expectFocusedAndVisible(firstSection);
    await key(LogicalKeyboardKey.space);
    expect(find.textContaining('El archivo local no está cifrado'), findsOneWidget);
    await key(LogicalKeyboardKey.space);
    expect(find.textContaining('El archivo local no está cifrado'), findsNothing);

    await key(LogicalKeyboardKey.tab, shift: true);
    final backButton = find.byIcon(Icons.arrow_back);
    expectFocusedAndVisible(backButton);
    await key(LogicalKeyboardKey.enter);
    expect(find.byType(PrivacyUsePage), findsNothing);
    expectFocusedAndVisible(privacyButton);
    await key(LogicalKeyboardKey.enter);
    expect(find.byType(PrivacyUsePage), findsOneWidget);

    final licensesButton = find.ancestor(
      of: find.text('Licencias de componentes'),
      matching: find.byType(OutlinedButton),
    );
    var licenseFocused = false;
    for (var i = 0; i < 48; i++) {
      await key(LogicalKeyboardKey.tab);
      if (licensesButton.evaluate().isNotEmpty &&
          focusCenter() == tester.getRect(licensesButton).center) {
        licenseFocused = true;
        break;
      }
    }
    expect(licenseFocused, isTrue);
    expectFocusedAndVisible(licensesButton);
    await key(LogicalKeyboardKey.enter);
    expect(find.byType(LicensePage), findsOneWidget);
    await key(LogicalKeyboardKey.tab, shift: true);
    await key(LogicalKeyboardKey.space);
    expect(find.byType(LicensePage), findsNothing);
    expect(find.byType(PrivacyUsePage), findsOneWidget);
  });

  testWidgets('texto al 200% en 360 px permite leer y abrir licencias',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const PrivacyUsePage(),
      ));
      await tester.pumpAndSettle();
      final outerScrollable = find.descendant(
        of: find.byType(PrivacyUsePage),
        matching: find.byType(Scrollable),
      ).first;
      await tester.scrollUntilVisible(
        find.text('Requisitos de accesibilidad'),
        250,
        scrollable: outerScrollable,
      );
      final accessibilityTitle = find.text('Requisitos de accesibilidad');
      await tester.ensureVisible(accessibilityTitle);
      await tester.pumpAndSettle();
      await tester.tap(accessibilityTitle);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Licencias de componentes'),
        250,
        scrollable: outerScrollable,
      );
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
    final licensesButton = find.text('Licencias de componentes');
    await tester.ensureVisible(licensesButton);
    await tester.pumpAndSettle();
    await tester.tap(licensesButton);
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guías de accesibilidad al 100% y 200% en 360 px',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final semantics = tester.ensureSemantics();
    try {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF176B55),
              surface: const Color(0xFFF8FAF8),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAF8),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const PrivacyUsePage(),
        ));
        await tester.pumpAndSettle();
        final scrollable = find.descendant(
          of: find.byType(PrivacyUsePage),
          matching: find.byType(Scrollable),
        ).first;
        final accessibilityTitle = find.text('Requisitos de accesibilidad');
        await tester.scrollUntilVisible(
          accessibilityTitle,
          220,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        await tester.tap(accessibilityTitle);
        await tester.pumpAndSettle();
        for (final guideline in [
          textContrastGuideline,
          labeledTapTargetGuideline,
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(guideline));
        }
        final licenses = find.text('Licencias de componentes');
        await tester.scrollUntilVisible(licenses, 220, scrollable: scrollable);
        await tester.pumpAndSettle();
        for (final guideline in [
          textContrastGuideline,
          labeledTapTargetGuideline,
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(guideline));
        }
      }
    } finally {
      semantics.dispose();
    }
  });
}
