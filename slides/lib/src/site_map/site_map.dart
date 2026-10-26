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
