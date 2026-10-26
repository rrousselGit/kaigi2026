import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slides/main.dart';
import 'package:slides/slides.dart';
import 'package:slides/widgets.dart';

import 'fonts.dart';

void main() {
  setUpAll(loadFonts);

  Future<void> pumpDeck(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 870);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SlidesApp());
  }

  Finder counter(int index) => find.text(
    '${'${index + 1}'.padLeft(2, '0')}  /  ${slides.length}',
    findRichText: true,
  );

  /// Presses "next" until the slide at [index] is shown.
  Future<void> goTo(WidgetTester tester, int index) async {
    while (counter(index).evaluate().isEmpty) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('every slide renders without overflow', (tester) async {
    await pumpDeck(tester);

    for (var i = 0; i < slides.length; i++) {
      expect(counter(i), findsOneWidget);
      expect(tester.takeException(), isNull, reason: slides[i].title);

      // Reveals every step, then moves to the next slide.
      for (var step = 0; step <= slides[i].steps; step++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('next reveals steps before moving on', (tester) async {
    await pumpDeck(tester);
    final index = slides.indexWhere((slide) => slide.steps > 0);
    await goTo(tester, index);

    int step() => SlideStep.of(tester.element(find.byType(Reveal).first));
    expect(step(), 0);

    for (var i = 1; i <= slides[index].steps; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(counter(index), findsOneWidget);
      expect(step(), i);
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(counter(index + 1), findsOneWidget);

    // Going back shows the previous slide fully revealed.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(counter(index), findsOneWidget);
    expect(step(), slides[index].steps);
  });

  testWidgets('presentation mode shows the notes and a timer', (tester) async {
    await pumpDeck(tester);
    // The presenter panel ticks every second, so pumpAndSettle never settles.
    Future<void> press(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump(const Duration(milliseconds: 500));
    }

    await press(LogicalKeyboardKey.keyP);
    expect(find.text('SPEAKER NOTES'), findsOne);
    expect(find.text(slides[0].notes), findsOne);
    expect(find.text('00:00'), findsOne);
    expect(find.text('Stop Presenting'), findsOne);

    for (var step = 0; step <= slides[0].steps; step++) {
      await press(LogicalKeyboardKey.arrowRight);
    }
    expect(find.text(slides[1].notes), findsOne);

    await press(LogicalKeyboardKey.keyP);
    await tester.pumpAndSettle();
    expect(find.text('SPEAKER NOTES'), findsNothing);
    expect(find.text('Present'), findsOne);
  });

  testWidgets('slides of a group share one live widget', (tester) async {
    await pumpDeck(tester);

    final first = slides.indexWhere((slide) => slide.group != null);
    final group = slides[first].group;
    await goTo(tester, first);
    for (var i = 0; i < slides[first].steps; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
    final type = slides[first].child.runtimeType;
    final element = tester.element(find.byType(type));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(slides[first + 1].group, group);
    // Updated in place: no second slide cross-fading in.
    expect(find.byType(type), findsOne);
    expect(tester.element(find.byType(type)), same(element));
  });
}
