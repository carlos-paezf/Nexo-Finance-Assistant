import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_offline_poc/main.dart';
import 'package:nexo_offline_poc/privacy_use_page.dart';

void main() {
  Future<ThemeData> nexoTheme(WidgetTester tester) async {
    await tester.pumpWidget(NexoPocApp(
      supportDirectoryProvider: () async =>
          throw const FileSystemException('Almacenamiento no disponible'),
    ));
    return tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
  }

  Future<void> pumpPrivacyPage(
    WidgetTester tester, {
    required ThemeData theme,
    required double textScale,
    Object instance = 'default',
  }) async {
    await tester.pumpWidget(MaterialApp(
      key: ValueKey('$textScale-$instance'),
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: const PrivacyUsePage(),
    ));
    await tester.pumpAndSettle();
  }

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
      final theme = await nexoTheme(tester);
      await pumpPrivacyPage(
        tester,
        theme: theme,
        textScale: 2,
        instance: 'text-200',
      );
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
      final theme = await nexoTheme(tester);
      Future<void> checkGuidelines() async {
        for (final guideline in [
          textContrastGuideline,
          labeledTapTargetGuideline,
          androidTapTargetGuideline,
          iOSTapTargetGuideline,
        ]) {
          await expectLater(tester, meetsGuideline(guideline));
        }
      }

      Future<Finder> pumpPage(double scale, Object instance) async {
        await pumpPrivacyPage(
          tester,
          theme: theme,
          textScale: scale,
          instance: instance,
        );
        return find.descendant(
          of: find.byType(PrivacyUsePage),
          matching: find.byType(Scrollable),
        ).first;
      }

      Future<void> reveal(Finder target, Finder scrollable) async {
        for (var i = 0; i < 80 && target.evaluate().isEmpty; i++) {
          await tester.drag(scrollable, const Offset(0, -220));
          await tester.pumpAndSettle();
        }
        expect(target, findsOneWidget);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
      }

      for (final scale in [1.0, 2.0]) {
        var scrollable = await pumpPage(scale, 'initial');
        await checkGuidelines();
        final viewport = Offset.zero &
            (tester.view.physicalSize / tester.view.devicePixelRatio);
        for (var index = 0; index < privacyUseSections.length; index++) {
          final section = privacyUseSections[index];
          scrollable = await pumpPage(scale, 'section-$index');
          final title = find.text(section.$1);
          final tile = find.ancestor(
            of: title,
            matching: find.byType(ExpansionTile),
          );
          final header = find.descendant(
            of: tile,
            matching: find.byType(ListTile),
          );
          await reveal(header, scrollable);
          expect(
            tester.getRect(header).overlaps(tester.getRect(scrollable)),
            isTrue,
          );
          expect(tester.getRect(header).overlaps(viewport), isTrue);
          final collapsedHint =
              tester.getSemantics(title).getSemanticsData().hint;
          tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
            tester.getSemantics(title).id,
            ui.SemanticsAction.tap,
          );
          await tester.pumpAndSettle();
          expect(
            tester.getSemantics(title).getSemanticsData().hint,
            isNot(collapsedHint),
          );
          final content = find.text(section.$2);
          expect(content, findsOneWidget);
          expect(find.byType(SelectableText), findsOneWidget);
          await Scrollable.ensureVisible(
            tester.element(content),
            alignment: 0.25,
          );
          await tester.pumpAndSettle();
          expect(tester.getRect(content).overlaps(viewport), isTrue);
          await checkGuidelines();
          expect(tester.takeException(), isNull);
        }

        scrollable = await pumpPage(scale, 'licenses');
        final licenses = find.text('Licencias de componentes');
        await reveal(licenses, scrollable);
        expect(tester.getRect(licenses).overlaps(viewport), isTrue);
        await checkGuidelines();
        expect(tester.takeException(), isNull);
      }
    } finally {
      semantics.dispose();
    }
  });
}
