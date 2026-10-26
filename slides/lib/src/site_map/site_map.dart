import 'package:material_ui/material_ui.dart';

class SiteMap {
  const SiteMap({required this.source, required this.routes});

  /// The folder the map describes, relative to the workspace root.
  final String source;

  /// All pages of the app, in the order the navigator stacks them.
  /// The first one is the home page.
  final List<RouteNode> routes;

  RouteNode? routeById(String id) {
    for (final route in routes) {
      if (route.id == id) return route;
    }
    return null;
  }
}

/// A page of the app.
class RouteNode {
  const RouteNode({
    required this.id,
    required this.title,
    required this.screen,
    required this.location,
    this.condition,
    this.params = const [],
    required this.elements,
    this.preview,
  });

  /// The page key, such as `product` for `ValueKey('product-$productId')`.
  final String id;

  final String title;

  /// The widget rendered by the page.
  final String screen;

  /// `file.dart:line` of the [screen] class.
  final String location;

  /// When the page is in the stack, or null if it always is.
  final String? condition;

  /// Variables of the page, such as `productId`.
  final List<String> params;

  /// What the user can tap on this page.
  final List<UiElement> elements;

  /// The real screen, filled with fake data, shown in place of the wireframe.
  final Widget? preview;
}

enum ElementKind { button, iconButton, tile, back }

/// Something tappable on a page.
class UiElement {
  const UiElement(
    this.kind,
    this.label, {
    required this.location,
    this.target,
    this.finder,
  });

  final ElementKind kind;
  final String label;

  /// `file.dart:line` where the element is created.
  final String location;

  /// The id of the [RouteNode] this element opens, if any.
  final String? target;

  /// Matches the widget of this element in [RouteNode.preview], so that
  /// arrows can start from it. The first match wins.
  final bool Function(Widget widget)? finder;
}

/// The devices pages can be previewed on.
enum PreviewDevice {
  phone('Phone', Size(390, 844)),
  smallPhone('Small phone', Size(360, 640)),
  tablet('Tablet', Size(768, 1024));

  const PreviewDevice(this.label, this.size);

  final String label;

  /// The logical size of the screen.
  final Size size;
}

/// The environment pages are previewed in, like the settings of a device.
@immutable
class PreviewSettings {
  const PreviewSettings({
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.device = PreviewDevice.phone,
  });

  /// The system's theme, which apps may follow.
  final Brightness brightness;

  /// The system's font size.
  final double textScale;
  final PreviewDevice device;

  PreviewSettings copyWith({
    Brightness? brightness,
    double? textScale,
    PreviewDevice? device,
  }) {
    return PreviewSettings(
      brightness: brightness ?? this.brightness,
      textScale: textScale ?? this.textScale,
      device: device ?? this.device,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PreviewSettings &&
      other.brightness == brightness &&
      other.textScale == textScale &&
      other.device == device;

  @override
  int get hashCode => Object.hash(brightness, textScale, device);
}
