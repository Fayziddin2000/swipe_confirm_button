@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_confirm_button/swipe_confirm_button.dart';

/// Loads Material icons (from the asset manifest) and a real text font so the
/// generated screenshots show readable text instead of placeholder boxes.
Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest) {
    final loader = FontLoader(family['family'] as String);
    for (final font in family['fonts'] as List) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }

  ByteData read(String path) =>
      ByteData.view(Uint8List.fromList(File(path).readAsBytesSync()).buffer);
  const regular = '/System/Library/Fonts/Supplemental/Arial.ttf';
  const bold = '/System/Library/Fonts/Supplemental/Arial Bold.ttf';
  if (File(regular).existsSync()) {
    final loader = FontLoader('Roboto')..addFont(Future.value(read(regular)));
    if (File(bold).existsSync()) loader.addFont(Future.value(read(bold)));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  final theme = ThemeData(
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget button, {
    SwipeButtonController? controller,
    void Function(SwipeButtonController)? drive,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(1500, 320);
    addTearDown(tester.view.reset);

    const key = ValueKey('shot');
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: 620,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: button,
            ),
          ),
        ),
      ),
    ));

    if (drive != null && controller != null) {
      drive(controller);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    } else {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await expectLater(
        find.byKey(key), matchesGoldenFile('../doc/images/$name.png'));
  }

  testWidgets('default', (tester) async {
    await shoot(
      tester,
      'default',
      const SwipeButton(
        text: 'Slide to confirm',
        hintAnimation: SwipeHintAnimation.none,
      ),
    );
  });

  testWidgets('styled', (tester) async {
    await shoot(
      tester,
      'styled',
      const SwipeButton(
        text: 'Pull to pay',
        height: 56,
        trackColor: Color(0xFF1B5E20),
        thumbColor: Colors.white,
        thumbIconColor: Color(0xFF1B5E20),
        progressColor: Color(0xFF2E7D32),
        textStyle: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        hintAnimation: SwipeHintAnimation.none,
      ),
    );
  });

  testWidgets('gradient', (tester) async {
    await shoot(
      tester,
      'gradient',
      const SwipeButton(
        text: 'Slide anywhere',
        draggableTrack: true,
        trackGradient:
            LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF7E57C2)]),
        thumbColor: Colors.white,
        thumbIconColor: Color(0xFF5E35B1),
        endIcon: Icons.check_rounded,
        textStyle: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        hintAnimation: SwipeHintAnimation.none,
      ),
    );
  });

  testWidgets('rounded', (tester) async {
    await shoot(
      tester,
      'rounded',
      SwipeButton(
        text: 'Slide to unlock',
        trackColor: const Color(0xFFE0E0E0),
        thumbColor: const Color(0xFF6750A4),
        thumbIconColor: Colors.white,
        textStyle: const TextStyle(
            color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
        trackPadding: const EdgeInsets.all(6),
        thumbElevation: 4,
        borderRadius: BorderRadius.circular(16),
        idleIcon: Icons.lock_rounded,
        hintAnimation: SwipeHintAnimation.none,
      ),
    );
  });

  testWidgets('success', (tester) async {
    final controller = SwipeButtonController();
    addTearDown(controller.dispose);
    await shoot(
      tester,
      'success',
      SwipeButton(
        controller: controller,
        text: 'Confirmed',
        collapseOnLoading: false,
        successColor: const Color(0xFF2E7D32),
        hintAnimation: SwipeHintAnimation.none,
      ),
      controller: controller,
      drive: (c) => c.success(),
    );
  });
}
