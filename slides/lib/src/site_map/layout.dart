import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'site_map.dart';

/// Sizes of a page frame. In wireframe mode, every row has a fixed height so
/// that the position of each button, where arrows start, is known without
/// measuring widgets. Previews are measured instead.
abstract final class FrameMetrics {
  static const width = 280.0;

  /// The logical size pages are previewed at, scaled down to [width].
  static const screen = Size(_screenWidth, _screenHeight);
  static const _screenWidth = 390.0;
  static const _screenHeight = 844.0;
  static const previewHeight = width * _screenHeight / _screenWidth;

  /// The page name written above the frame, like in Figma.
  static const label = 28.0;
  static const appBar = 52.0;
  static const condition = 34.0;
  static const listPadding = 10.0;
  static const element = 44.0;
  static const footer = 40.0;

  static const columnGap = 180.0;
  static const rowGap = 64.0;

  /// The height of a frame listing [elements] buttons.
  static double heightOf(int elements, {required bool previews}) => previews
      ? label + previewHeight
      : label +
            appBar +
            condition +
            listPadding * 2 +
            math.max(elements, 1) * element +
            footer;

  /// The vertical center of the [index]th element, relative to the frame.
  static double elementY(int index) =>
      label + appBar + condition + listPadding + element * (index + 0.5);

  /// Where arrows pointing to a page end, relative to the frame.
  static double entryY({required bool previews}) =>
      previews ? label + 48 : label + appBar / 2;
}

class Link {
  Link(this.from, this.elementIndex, this.to);

  final RouteNode from;
  final int elementIndex;
  final RouteNode to;
}

/// Places pages in columns, by how many taps it takes to reach them from the
/// home page: the result reads left-to-right like a user journey.
///
/// Frames are keyed by page id. When given a [base] version of the map, the
/// layout makes room for the pages of both versions, so that switching between
/// them only moves what changed.
class SiteMapLayout {
  factory SiteMapLayout(
    SiteMap siteMap, {
    required bool previews,
    SiteMap? base,
  }) {
    final versions = [siteMap, ?base];
    final ids = <String>{
      for (final version in versions)
        for (final route in version.routes) route.id,
    };
    // Links between page ids, in any version.
    final edges = {
      for (final version in versions)
        for (final link in linksOf(version)) (link.from.id, link.to.id),
    };
    int elementsOf(String id) => versions
        .map((version) => version.routeById(id)?.elements.length ?? 0)
        .reduce(math.max);

    final depth = <String, int>{};
    if (ids.isNotEmpty) {
      depth[ids.first] = 0;
      final queue = Queue.of([ids.first]);
      while (queue.isNotEmpty) {
        final id = queue.removeFirst();
        for (final (from, to) in edges) {
          if (from != id || depth.containsKey(to)) continue;
          depth[to] = depth[id]! + 1;
          queue.add(to);
        }
      }
    }
    // Pages no button leads to still get a column, after the reachable ones.
    final unreachable = depth.values.fold(-1, math.max) + 1;
    for (final id in ids) {
      depth.putIfAbsent(id, () => unreachable);
    }

    final columns = <int, List<String>>{};
    for (final id in ids) {
      columns.putIfAbsent(depth[id]!, () => []).add(id);
    }
    double heightOf(String id) =>
        FrameMetrics.heightOf(elementsOf(id), previews: previews);
    double columnHeight(List<String> column) =>
        column.map(heightOf).reduce((a, b) => a + b) +
        FrameMetrics.rowGap * (column.length - 1);
    final tallest = columns.values.map(columnHeight).fold(0.0, math.max);

    final frames = <String, Rect>{};
    for (final MapEntry(key: column, value: ids) in columns.entries) {
      final x = column * (FrameMetrics.width + FrameMetrics.columnGap);
      var y = (tallest - columnHeight(ids)) / 2;
      for (final id in ids) {
        frames[id] = Rect.fromLTWH(x, y, FrameMetrics.width, heightOf(id));
        y += heightOf(id) + FrameMetrics.rowGap;
      }
    }

    return SiteMapLayout._(frames, depth, linksOf(siteMap), previews);
  }

  SiteMapLayout._(this.frames, this.depth, this.links, this.previews);

  /// The arrows of [siteMap]: one per button leading to a page.
  static List<Link> linksOf(SiteMap siteMap) => [
    for (final route in siteMap.routes)
      for (final (index, element) in route.elements.indexed)
        if (element.target case final target?)
          if (siteMap.routeById(target) case final to?) Link(route, index, to),
  ];

  /// Whether frames show the real pages, rather than wireframes.
  final bool previews;

  final Map<String, Rect> frames;
  final Map<String, int> depth;

  /// The links of the map the layout was made for (not of its base).
  final List<Link> links;

  Rect get bounds => frames.values.fold(
    Rect.zero,
    (bounds, rect) => bounds.expandToInclude(rect),
  );

  /// The path of an arrow, from the right edge of a button to a page.
  ///
  /// [start] is where the button was measured in a preview. By default, it is
  /// its row in the wireframe.
  ///
  /// Arrows going forward are smooth curves. Arrows going back to an earlier
  /// column loop under the whole map, and arrows within a column bend around
  /// the right side of the column.
  Path pathOf(Link link, {required int lane, Offset? start}) {
    final from = frames[link.from.id]!;
    final to = frames[link.to.id]!;
    start ??= Offset(
      from.right,
      from.top + FrameMetrics.elementY(link.elementIndex),
    );
    final entryY = to.top + FrameMetrics.entryY(previews: previews);
    final fromDepth = depth[link.from.id]!;
    final toDepth = depth[link.to.id]!;

    if (toDepth > fromDepth) {
      final end = Offset(to.left, entryY);
      final pull =
          math.max((end.dx - from.right) / 2, 60.0) +
          (from.right - start.dx) / 2;
      return Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + pull,
          start.dy,
          end.dx - pull,
          end.dy,
          end.dx,
          end.dy,
        );
    }

    final out = 36.0 + lane * 14;
    if (toDepth == fromDepth) {
      final end = Offset(to.right, entryY);
      return _rounded([
        start,
        Offset(from.right + out, start.dy),
        Offset(from.right + out, end.dy),
        end,
      ]);
    }

    final end = Offset(to.left, entryY);
    final below = bounds.bottom + 48 + lane * 14;
    return _rounded([
      start,
      Offset(from.right + out, start.dy),
      Offset(from.right + out, below),
      Offset(end.dx - out, below),
      Offset(end.dx - out, end.dy),
      end,
    ]);
  }

  /// A polyline through [points], with rounded corners.
  static Path _rounded(List<Offset> points, {double radius = 18}) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final previous = points[i - 1];
      final corner = points[i];
      final next = points[i + 1];
      final r = math.min(
        radius,
        math.min((corner - previous).distance, (next - corner).distance) / 2,
      );
      final before = corner - _direction(corner - previous) * r;
      final after = corner + _direction(next - corner) * r;
      path
        ..lineTo(before.dx, before.dy)
        ..quadraticBezierTo(corner.dx, corner.dy, after.dx, after.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  static Offset _direction(Offset offset) =>
      offset.distance == 0 ? Offset.zero : offset / offset.distance;
}
