import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:slides/main.dart';
import 'package:slides/slides.dart';

import 'fonts.dart';

void main() {
  setUpAll(loadFonts);

  testWidgets('every slide renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(1440, 870);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SlidesApp());

    for (var i = 0; i < slides.length; i++) {
      final label = '${i + 1}'.padLeft(2, '0');
      expect(
        find.text('$label  /  ${slides.length}', findRichText: true),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull, reason: slides[i].title);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('slides of a group share one live widget', (tester) async {
    tester.view.physicalSize = const Size(1440, 870);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SlidesApp());

    final first = slides.indexWhere((slide) => slide.group != null);
    final group = slides[first].group;
    for (var i = 0; i < first; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(InteractiveViewer));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(slides[first + 1].group, group);
    // Updated in place: no second slide cross-fading in.
    expect(find.byType(InteractiveViewer), findsOne);
    expect(tester.state(find.byType(InteractiveViewer)), same(state));
  });
}
