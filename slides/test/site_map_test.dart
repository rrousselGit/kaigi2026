import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:slides/src/example_1/models.dart';
import 'package:slides/src/example_1/shop_app.dart';
import 'package:slides/src/site_map/shoply.dart';
import 'package:slides/src/site_map/site_map_view.dart';

import 'fonts.dart';

Future<TransformationController> _pumpSiteMap(
  WidgetTester tester, {
  bool previews = false,
}) async {
  tester.view
    ..physicalSize = const Size(1800, 1100)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox(
          width: 1600,
          height: 900,
          child: SiteMapView(siteMap: shoplySiteMap, previews: previews),
        ),
      ),
    ),
  );
  return tester
      .widget<InteractiveViewer>(find.byType(InteractiveViewer))
      .transformationController!;
}

double _scaleOf(TransformationController transform) =>
    transform.value.getMaxScaleOnAxis();

void main() {
  setUpAll(loadFonts);

  testWidgets('starts zoomed out to fit the map', (tester) async {
    final transform = await _pumpSiteMap(tester);

    expect(_scaleOf(transform), lessThan(1));
    expect(find.text('${(_scaleOf(transform) * 100).round()}%'), findsOne);
  });

  testWidgets('zooms with the mouse wheel', (tester) async {
    final transform = await _pumpSiteMap(tester);
    final before = _scaleOf(transform);

    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    final center = tester.getCenter(find.byType(InteractiveViewer));
    await tester.sendEventToBinding(mouse.hover(center));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, -100)));
    await tester.pump();

    expect(_scaleOf(transform), greaterThan(before));
  });

  testWidgets('zooms with a trackpad pinch', (tester) async {
    final transform = await _pumpSiteMap(tester);
    final before = _scaleOf(transform);

    final trackpad = TestPointer(1, PointerDeviceKind.trackpad);
    final center = tester.getCenter(find.byType(InteractiveViewer));
    await tester.sendEventToBinding(trackpad.panZoomStart(center));
    await tester.sendEventToBinding(trackpad.panZoomUpdate(center, scale: 1.5));
    await tester.sendEventToBinding(trackpad.panZoomEnd());
    await tester.pump();

    expect(_scaleOf(transform), closeTo(before * 1.5, 0.01));
  });

  testWidgets('zooms with the toolbar buttons', (tester) async {
    final transform = await _pumpSiteMap(tester);
    final before = _scaleOf(transform);

    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    expect(_scaleOf(transform), closeTo(before * 1.25, 0.01));

    await tester.tap(find.byTooltip('Zoom out'));
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.pump();
    expect(_scaleOf(transform), closeTo(before / 1.25, 0.01));

    await tester.tap(find.byTooltip('Fit to screen'));
    await tester.pump();
    expect(_scaleOf(transform), closeTo(before, 0.01));
  });

  testWidgets('keeps the map centered when zooming far out', (tester) async {
    final transform = await _pumpSiteMap(tester);
    final viewer = find.byType(InteractiveViewer);
    final center = tester.getCenter(viewer);
    Offset mapCenter() => tester.getCenter(find.text('Order placed').first);
    final before = mapCenter();

    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(mouse.hover(center));
    for (var i = 0; i < 20; i++) {
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 100)));
    }
    await tester.pump();

    expect(_scaleOf(transform), closeTo(0.2, 0.001));
    // Zooming around the center moves points towards it, never past it.
    final after = mapCenter();
    expect(after.dx, inInclusiveRange(center.dx, before.dx));
  });

  group('focusing a screen', () {
    /// The state of the catalog's preview.
    ShopState catalog(WidgetTester tester) => tester
        .widget<ShopScope>(
          find.ancestor(
            of: find.text('Shoply'),
            matching: find.byType(ShopScope),
          ),
        )
        .state;

    /// Double-taps the page showing [finder], which ignores the pointer.
    Future<void> doubleTap(WidgetTester tester, Finder finder) async {
      await tester.tap(finder, warnIfMissed: false);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(finder, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    testWidgets('passes clicks to the app, except links', (tester) async {
      await _pumpSiteMap(tester, previews: true);
      await tester.pumpAndSettle();

      // Not focused: the page is only a picture.
      await tester.tap(find.text('Audio'), warnIfMissed: false);
      await tester.pump(kDoubleTapTimeout);
      expect(catalog(tester).category, 'All');
      expect(find.text('LIVE'), findsNothing);

      await doubleTap(tester, find.text('Shoply'));
      expect(find.text('LIVE'), findsOne);

      await tester.tap(find.text('Audio'));
      await tester.pumpAndSettle();
      expect(catalog(tester).category, 'Audio');

      // Product cards open another page: they do nothing.
      await tester.tap(
        find.text('Studio Headphones').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(catalog(tester).productId, isNull);
    });

    testWidgets('scrolls the app rather than zooming the map', (tester) async {
      final transform = await _pumpSiteMap(tester, previews: true);
      await tester.pumpAndSettle();
      await doubleTap(tester, find.text('Shoply'));
      final scale = _scaleOf(transform);

      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      final banner = find.text('SUMMER SALE');
      final top = tester.getTopLeft(banner).dy;
      await tester.sendEventToBinding(mouse.hover(tester.getCenter(banner)));
      await tester.pump();
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 200)));
      await tester.pumpAndSettle();
      expect(_scaleOf(transform), scale);
      // The catalog scrolled instead.
      expect(tester.getTopLeft(banner).dy, lessThan(top));
    });

    testWidgets('zooms on the page', (tester) async {
      final transform = await _pumpSiteMap(tester, previews: true);
      await tester.pumpAndSettle();
      final scale = _scaleOf(transform);

      await doubleTap(tester, find.text('Shoply'));
      expect(_scaleOf(transform), greaterThan(scale));
      // The page fills the height below the toolbar.
      final page = tester.getRect(find.text('Shoply')).center;
      final viewer = tester.getRect(find.byType(InteractiveViewer));
      expect(page.dx, inInclusiveRange(viewer.left, viewer.right));
      expect(page.dy, inInclusiveRange(viewer.top, viewer.bottom));
    });

    testWidgets('still zooms the map outside the page', (tester) async {
      final transform = await _pumpSiteMap(tester, previews: true);
      await tester.pumpAndSettle();
      await doubleTap(tester, find.text('Shoply'));
      final scale = _scaleOf(transform);

      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      final viewer = tester.getRect(find.byType(InteractiveViewer));
      await tester.sendEventToBinding(
        mouse.hover(viewer.bottomLeft + const Offset(40, -40)),
      );
      await tester.pump();
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 100)));
      await tester.pumpAndSettle();
      expect(_scaleOf(transform), lessThan(scale));
      expect(find.text('LIVE'), findsOne);
    });

    testWidgets('clicking outside unfocuses', (tester) async {
      await _pumpSiteMap(tester, previews: true);
      await tester.pumpAndSettle();
      await doubleTap(tester, find.text('Shoply'));
      expect(find.text('LIVE'), findsOne);

      await tester.tapAt(const Offset(150, 950));
      await tester.pumpAndSettle();
      expect(find.text('LIVE'), findsNothing);
    });
  });
}
