import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_confirm_button/swipe_confirm_button.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('renders the label text and idle icon', (tester) async {
    await tester.pumpWidget(_wrap(
      const SwipeButton(text: 'Slide to confirm'),
    ));
    expect(find.text('Slide to confirm'), findsOneWidget);
    expect(
        find.byIcon(Icons.keyboard_double_arrow_right_rounded), findsOneWidget);
  });

  testWidgets('a full swipe fires onSwipe and shows loading then success',
      (tester) async {
    var fired = false;
    final completer = Completer<void>();

    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 300,
        child: SwipeButton(
          text: 'Confirm',
          onSwipe: () {
            fired = true;
            return completer.future;
          },
        ),
      ),
    ));

    // The drag handler lives on the thumb, so grab it by its idle icon.
    await tester.drag(
      find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      const Offset(300, 0),
    );
    await tester.pump();

    expect(fired, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('a short swipe below threshold does not fire onSwipe',
      (tester) async {
    var fired = false;
    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 300,
        child: SwipeButton(
          text: 'Confirm',
          hintAnimation: SwipeHintAnimation.none,
          onSwipe: () => fired = true,
        ),
      ),
    ));

    await tester.drag(
      find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();

    expect(fired, isFalse);
  });

  testWidgets('fires onSwipeStart and onSwipeEnd around a drag',
      (tester) async {
    final events = <String>[];
    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 300,
        child: SwipeButton(
          text: 'Confirm',
          onSwipeStart: () => events.add('start'),
          onSwipeEnd: () => events.add('end'),
          onSwipe: () => events.add('swipe'),
        ),
      ),
    ));

    await tester.drag(
      find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      const Offset(300, 0),
    );
    await tester.pump();

    expect(events, ['start', 'end', 'swipe']);
  });

  testWidgets('SwipeButton.expand builds and confirms', (tester) async {
    var fired = false;
    await tester.pumpWidget(_wrap(
      SwipeButton.expand(
        text: 'Expand',
        onSwipe: () => fired = true,
      ),
    ));

    expect(find.text('Expand'), findsOneWidget);
    await tester.drag(
      find.byIcon(Icons.keyboard_double_arrow_right_rounded),
      const Offset(2000, 0),
    );
    await tester.pump();
    expect(fired, isTrue);
  });

  testWidgets('thumbBuilder overrides the default thumb content',
      (tester) async {
    await tester.pumpWidget(_wrap(
      SwipeButton(
        text: 'Custom',
        thumbBuilder: (context, status) => const Icon(Icons.bolt),
      ),
    ));
    expect(find.byIcon(Icons.bolt), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_double_arrow_right_rounded), findsNothing);
  });

  testWidgets('dragEffect eases in on grab and settles on release',
      (tester) async {
    var started = false;
    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 300,
        child: SwipeButton(
          text: 'X',
          hintAnimation: SwipeHintAnimation.none,
          dragEffect: SwipeDragEffect.growLift,
          onSwipeStart: () => started = true,
        ),
      ),
    ));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.keyboard_double_arrow_right_rounded)),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0)); // recognize the horizontal drag
    await tester.pump();

    expect(started, isTrue);
    // The press controller is easing in, so a frame is scheduled.
    expect(tester.binding.hasScheduledFrame, isTrue);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('rollIcon rotates the idle icon as it travels', (tester) async {
    await tester.pumpWidget(_wrap(
      SizedBox(
        width: 300,
        child: SwipeButton(
          text: 'X',
          hintAnimation: SwipeHintAnimation.none,
          dragEffect: SwipeDragEffect.none,
          rollIcon: true,
        ),
      ),
    ));

    final icon = find.byIcon(Icons.keyboard_double_arrow_right_rounded);
    final gesture = await tester.startGesture(tester.getCenter(icon));
    await tester.pump();
    await gesture.moveBy(const Offset(30, 0)); // exceed touch slop -> start drag
    await tester.pump();
    await gesture.moveBy(const Offset(90, 0)); // travel further
    await tester.pump();

    // A Transform ancestor of the icon now carries a rotation (off-diagonal
    // matrix terms are non-zero).
    final rotated = tester
        .widgetList<Transform>(
            find.ancestor(of: icon, matching: find.byType(Transform)))
        .any((t) => t.transform.entry(0, 1) != 0 || t.transform.entry(1, 0) != 0);
    expect(rotated, isTrue);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('idle hint animation keeps the icon ticking', (tester) async {
    await tester.pumpWidget(_wrap(
      const SwipeButton(text: 'Hint', hintAnimation: SwipeHintAnimation.pulse),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The looping hint controller keeps scheduling frames while idle.
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('hintAnimation.none leaves an idle button fully settled',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const SwipeButton(text: 'No hint', hintAnimation: SwipeHintAnimation.none),
    ));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('controller.complete() confirms programmatically',
      (tester) async {
    final controller = SwipeButtonController();
    addTearDown(controller.dispose);
    var fired = false;

    await tester.pumpWidget(_wrap(
      SwipeButton(
        controller: controller,
        text: 'Confirm',
        hintAnimation: SwipeHintAnimation.none,
        onSwipe: () => fired = true,
      ),
    ));

    controller.complete();
    await tester.pumpAndSettle();
    expect(fired, isTrue);
  });

  testWidgets('the Semantics tap action confirms (a11y)', (tester) async {
    final handle = tester.ensureSemantics();
    var fired = false;

    await tester.pumpWidget(_wrap(
      SwipeButton(
        text: 'Confirm',
        hintAnimation: SwipeHintAnimation.none,
        onSwipe: () => fired = true,
      ),
    ));

    final node = tester.getSemantics(find.byType(SwipeButton));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    // Perform the semantic tap as a screen reader would.
    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!
        .performAction(node.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(fired, isTrue);
    handle.dispose();
  });

  testWidgets('reduced motion stops the idle hint loop', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const Scaffold(
          body: Center(child: SwipeButton(text: 'Hi')),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // With animations disabled, the hint must not keep scheduling frames.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('SwipeButtonTheme supplies defaults', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        extensions: const [SwipeButtonThemeData(height: 40)],
      ),
      home: const Scaffold(
        body: Center(child: SwipeButton(text: 'Themed')),
      ),
    ));
    final size = tester.getSize(find.byType(SwipeButton));
    expect(size.height, 40);
  });

  testWidgets('external controller drives the visual status', (tester) async {
    final controller = SwipeButtonController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_wrap(
      SwipeButton(
        controller: controller,
        text: 'Confirm',
        hintAnimation: SwipeHintAnimation.none,
      ),
    ));

    controller.loading();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.success();
    await tester.pump();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    controller.reset();
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
  });
}
