import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:slides/src/example_1/models.dart';
import 'package:slides/src/example_1/shop_app.dart';

import 'fonts.dart';

Future<void> _pumpShop(WidgetTester tester, ShopState state) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: ShopApp(state: state)));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.hitTestable().first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadFonts);

  testWidgets('can be clicked through, from catalog to order', (tester) async {
    await _pumpShop(tester, const ShopState());

    await _tap(tester, find.text('Studio Headphones'));
    expect(find.text('Add to cart').hitTestable(), findsOne);

    await _tap(tester, find.text('Add to cart'));
    expect(find.text('In cart · 1').hitTestable(), findsOne);

    await _tap(tester, find.byIcon(Icons.shopping_bag_outlined));
    expect(find.text('My cart (1)').hitTestable(), findsOne);

    await _tap(tester, find.byIcon(Icons.add_rounded));
    expect(find.text('My cart (2)').hitTestable(), findsOne);

    await _tap(tester, find.textContaining('Checkout ·'));
    await _tap(tester, find.textContaining('Place order'));
    expect(find.text('Order placed!').hitTestable(), findsOne);

    await _tap(tester, find.text('Continue shopping'));
    expect(find.text('Popular right now').hitTestable(), findsOne);
    expect(find.text('Order placed!'), findsNothing);
  });

  testWidgets('goes back with the back button', (tester) async {
    await _pumpShop(tester, const ShopState(productId: 'watch'));
    expect(find.text('Smart Watch S2').hitTestable(), findsOne);

    await _tap(tester, find.byIcon(Icons.arrow_back_rounded));
    expect(find.text('Popular right now').hitTestable(), findsOne);
  });

  testWidgets('filters by category', (tester) async {
    await _pumpShop(tester, const ShopState());

    await _tap(tester, find.text('Wearables'));
    expect(find.text('Smart Watch S2').hitTestable(), findsOne);
    expect(find.text('Studio Headphones'), findsNothing);
  });

  testWidgets('resets clicks when the slide changes the state', (tester) async {
    await _pumpShop(tester, const ShopState());
    await _tap(tester, find.text('Studio Headphones'));
    expect(find.text('Add to cart').hitTestable(), findsOne);

    await _pumpShop(tester, const ShopState(cartOpen: true));
    expect(find.text('My cart (0)').hitTestable(), findsOne);
    expect(find.text('Add to cart'), findsNothing);
  });
}
