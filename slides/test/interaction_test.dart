import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slides/main.dart';
import 'package:slides/slides.dart';

import 'fonts.dart';

/// Clicking and scrolling the example app as a presenter would, with a mouse
/// or trackpad, in the deck.
void main() {
  setUpAll(loadFonts);

  Future<void> goTo(WidgetTester tester, String title) async {
    tester.view
      ..physicalSize = const Size(1440, 870)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SlidesApp());
    final index = slides.indexWhere((slide) => slide.title == title);
    for (var i = 0; i < index; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    }
    await tester.pumpAndSettle();
  }

  /// Clicks with a mouse that moves slightly while pressed, as real clicks do.
  Future<void> click(WidgetTester tester, Finder finder) async {
    final mouse = await tester.startGesture(
      tester.getCenter(finder),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump(const Duration(milliseconds: 50));
    await mouse.moveBy(const Offset(2, 3));
    await tester.pump(const Duration(milliseconds: 20));
    await mouse.up();
    await mouse.removePointer();
    await tester.pumpAndSettle();
  }

  Future<void> trackpadScroll(WidgetTester tester, Finder finder) async {
    final trackpad = TestPointer(1, PointerDeviceKind.trackpad);
    final at = tester.getCenter(finder);
    await tester.sendEventToBinding(trackpad.panZoomStart(at));
    for (var i = 1; i <= 10; i++) {
      await tester.sendEventToBinding(
        trackpad.panZoomUpdate(at, pan: Offset(0, -10.0 * i)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.sendEventToBinding(trackpad.panZoomEnd());
    await tester.pumpAndSettle();
  }

  group('side panel', () {
    testWidgets('clicks products in the scrolling catalog', (tester) async {
      await goTo(tester, 'Example: Shoply');

      await click(tester, find.text('Smart Watch S2'));
      expect(find.text('About'), findsOne);
    });

    testWidgets('scrolls with a trackpad', (tester) async {
      await goTo(tester, 'Example: Shoply');
      final title = find.text('Popular right now');
      final top = tester.getTopLeft(title).dy;

      await trackpadScroll(tester, title);
      expect(tester.getTopLeft(title).dy, lessThan(top));
    });
  });

  group('live site map page', () {
    Future<void> goLive(WidgetTester tester) async {
      await goTo(tester, 'DevTool: Site Map Screens');
      for (var i = 0; i < 2; i++) {
        final mouse = await tester.startGesture(
          tester.getCenter(find.text('Shoply')),
          kind: PointerDeviceKind.mouse,
        );
        await mouse.up();
        await mouse.removePointer();
        await tester.pump(kDoubleTapMinTime);
      }
      await tester.pumpAndSettle();
      expect(find.text('LIVE'), findsOne);
    }

    testWidgets('clicks categories in the scrolling catalog', (tester) async {
      await goLive(tester);

      await click(tester, find.text('Audio'));
      expect(find.text('Smart Watch S2'), findsNothing);
    });

    /// How far the catalog showing [finder] is scrolled.
    double offsetOf(WidgetTester tester, Finder finder) => tester
        .state<ScrollableState>(
          find.ancestor(of: finder, matching: find.byType(Scrollable)).first,
        )
        .position
        .pixels;

    Future<void> wheelScroll(WidgetTester tester, Finder finder) async {
      final mouse = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(tester.getCenter(finder)));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 60)));
      await tester.pumpAndSettle();
    }

    testWidgets('scrolls with a trackpad and a wheel', (tester) async {
      await goLive(tester);
      final title = find.text('Popular right now').hitTestable();

      await trackpadScroll(tester, title);
      final scrolled = offsetOf(tester, title);
      expect(scrolled, greaterThan(0));

      await wheelScroll(tester, title);
      expect(offsetOf(tester, title), greaterThan(scrolled));
    });

    // Product cards open another page, so clicking them does nothing; but
    // scrolling must still work when it starts over them.
    testWidgets('scrolls when starting over a product card', (tester) async {
      await goLive(tester);
      final card = find.text('Smart Watch S2').hitTestable();

      await wheelScroll(tester, card);
      final scrolled = offsetOf(tester, find.text('Smart Watch S2'));
      expect(scrolled, greaterThan(0));

      await trackpadScroll(tester, card);
      expect(
        offsetOf(tester, find.text('Smart Watch S2')),
        greaterThan(scrolled),
      );
    });
  });
}
