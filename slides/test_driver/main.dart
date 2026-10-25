import 'package:flutter_driver/driver_extension.dart';
import 'package:slides/main.dart' as app;

/// Runs the slides with the flutter_driver extension enabled, so that tools
/// (such as the Dart MCP server) can take screenshots and send input.
///
/// ```sh
/// flutter run -d macos -t test_driver/main.dart
/// ```
void main() {
  enableFlutterDriverExtension();
  app.main();
}
