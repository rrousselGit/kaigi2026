import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the real fonts, so that overflow checks match what's on screen.
Future<void> loadFonts() async {
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
