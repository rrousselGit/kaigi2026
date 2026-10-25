import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slides/main.dart';
import 'package:slides/slides.dart';

/// Loads the real fonts, so that overflow checks match what's on screen.
Future<void> _loadFonts() async {
  const families = {
    'Inter': 'inter',
    'Outfit': 'outfit',
    'FiraCode': 'fira-code',
  };
  for (final MapEntry(key: family, value: prefix) in families.entries) {
    final loader = FontLoader(family);
    for (final file in Directory('assets/fonts').listSync()) {
      if (file.uri.pathSegments.last.startsWith('$prefix-')) {
        final bytes = File(file.path).readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('every slide renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(1440, 870);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SlidesApp());

    for (var i = 0; i < slides.length; i++) {
      expect(find.text('Slide ${i + 1} / ${slides.length}'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: slides[i].title);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
  });
}
