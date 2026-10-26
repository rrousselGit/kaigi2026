import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:slides/src/site_map/diff.dart';
import 'package:slides/src/site_map/shoply.dart';
import 'package:slides/src/site_map/site_map_view.dart';

Future<void> _pumpDiff(
  WidgetTester tester, {
  SiteMapDiff? diff,
  bool highlight = true,
}) async {
  tester.view
    ..physicalSize = const Size(2000, 1100)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: SizedBox(
          width: 1900,
          height: 900,
          child: SiteMapView.diff(
            diff ?? shoplyWishlistDiff,
            highlight: highlight,
          ),
        ),
      ),
    ),
  );
}

/// The opacity of the frame of the page titled [title], in the board.
double _opacityOf(WidgetTester tester, String title) {
  final opacity = find.ancestor(
    of: find.text(title).first,
    matching: find.byType(AnimatedOpacity),
  );
  return tester.widget<AnimatedOpacity>(opacity.first).opacity;
}

void main() {
  final diff = shoplyWishlistDiff;

  test('finds the added and modified pages', () {
    expect(diff.routeChange('wishlist'), Change.added);
    // Its favorites button now opens the wishlist.
    expect(diff.routeChange('catalog'), Change.modified);
    for (final id in ['product', 'cart', 'checkout', 'confirmed']) {
      expect(diff.routeChange(id), Change.unchanged, reason: id);
    }
    expect(diff.changedRouteIds, ['catalog', 'wishlist']);
  });

  test('finds the added links', () {
    expect(diff.removedLinks, 0);
    expect(
      [
        for (final link in diff.headLinks)
          if (diff.linkChange(link, inHead: true) == Change.added)
            '${link.from.id} -> ${link.to.id}',
      ],
      ['catalog -> wishlist', 'wishlist -> product', 'wishlist -> cart'],
    );
  });

  testWidgets('hides the new page before the change', (tester) async {
    await _pumpDiff(tester);
    expect(_opacityOf(tester, 'Saved product'), 1);

    await tester.tap(find.text('Before · main'));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, 'Saved product'), 0);

    await tester.tap(find.text('After · feature/wishlist'));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, 'Saved product'), 1);
  });

  testWidgets('dims unchanged pages while highlighting', (tester) async {
    await _pumpDiff(tester);
    expect(find.text('CHANGED'), findsWidgets);
    expect(_opacityOf(tester, 'Add to cart'), lessThan(1));

    await tester.tap(find.text('Highlight changes'));
    await tester.pumpAndSettle();
    expect(find.text('CHANGED'), findsOne, reason: 'only in the panel');
    expect(_opacityOf(tester, 'Add to cart'), 1);
  });

  test('finds changes to existing pages', () {
    final diff = shoplyBuyNowDiff;
    expect(diff.changedRouteIds, ['product', 'checkout']);
    for (final id in diff.changedRouteIds) {
      expect(diff.routeChange(id), Change.modified, reason: id);
    }
    expect(
      [
        for (final link in diff.headLinks)
          if (diff.linkChange(link, inHead: true) == Change.added)
            '${link.from.id} -> ${link.to.id}',
      ],
      ['product -> checkout', 'checkout -> cart'],
    );
  });

  testWidgets('follows the highlight it is given', (tester) async {
    await _pumpDiff(tester, diff: shoplyBuyNowDiff, highlight: false);
    expect(find.text('CHANGED'), findsNWidgets(2), reason: 'only the panel');

    await _pumpDiff(tester, diff: shoplyBuyNowDiff);
    await tester.pumpAndSettle();
    expect(find.text('CHANGED'), findsNWidgets(4), reason: 'panel and map');
  });
}
