import 'layout.dart';
import 'site_map.dart';

enum Change { added, removed, modified, unchanged }

/// A file of the git diff, as in `git diff --stat`.
class FileChange {
  const FileChange(
    this.path, {
    required this.change,
    this.additions = 0,
    this.deletions = 0,
    this.declarations = const [],
  });

  final String path;
  final Change change;
  final int additions;
  final int deletions;

  /// The classes the changes are in, as git shows in hunk headers:
  /// `@@ -64,7 +64,9 @@ class CheckoutScreen`.
  final List<String> declarations;
}

/// What changed in the site map between two git refs.
///
/// Pages are matched by id, and buttons by kind and label. A page is also
/// modified when its screen's code is in the [files] diff, even if none of its
/// buttons changed: it may look different.
class SiteMapDiff {
  SiteMapDiff({
    required this.base,
    required this.head,
    required this.baseRef,
    required this.headRef,
    required this.files,
  });

  final SiteMap base;
  final SiteMap head;
  final String baseRef;
  final String headRef;
  final List<FileChange> files;

  /// The pages of both versions: the head's, then those it removed.
  late final List<String> routeIds = [
    for (final route in head.routes) route.id,
    for (final route in base.routes)
      if (head.routeById(route.id) == null) route.id,
  ];

  late final List<Link> baseLinks = SiteMapLayout.linksOf(base);
  late final List<Link> headLinks = SiteMapLayout.linksOf(head);

  late final List<String> changedRouteIds = [
    for (final id in routeIds)
      if (routeChange(id) != Change.unchanged) id,
  ];

  late final int addedLinks = headLinks
      .where((link) => linkChange(link, inHead: true) != Change.unchanged)
      .length;
  late final int removedLinks = baseLinks
      .where((link) => linkChange(link, inHead: false) != Change.unchanged)
      .length;

  Change routeChange(String id) {
    final before = base.routeById(id);
    final after = head.routeById(id);
    if (before == null) return Change.added;
    if (after == null) return Change.removed;

    final changed =
        files.any(
          (file) =>
              file.declarations.contains(after.screen) ||
              file.declarations.contains('_${after.screen}State'),
        ) ||
        before.screen != after.screen ||
        before.condition != after.condition ||
        before.params.join() != after.params.join() ||
        before.elements.length != after.elements.length ||
        after.elements.any(
          (element) =>
              elementChange(id, element, inHead: true) != Change.unchanged,
        );
    return changed ? Change.modified : Change.unchanged;
  }

  /// How [element], of the page [routeId] in the base or head, changed.
  Change elementChange(
    String routeId,
    UiElement element, {
    required bool inHead,
  }) {
    final other = (inHead ? base : head).routeById(routeId);
    if (other == null) return inHead ? Change.added : Change.removed;

    final key = _keyOf(element);
    for (final candidate in other.elements) {
      if (_keyOf(candidate) != key) continue;
      return candidate.target == element.target
          ? Change.unchanged
          : Change.modified;
    }
    return inHead ? Change.added : Change.removed;
  }

  /// Whether the arrow [link] is new in the head, or gone from the base.
  Change linkChange(Link link, {required bool inHead}) {
    final element = link.from.elements[link.elementIndex];
    return switch (elementChange(link.from.id, element, inHead: inHead)) {
      Change.unchanged => Change.unchanged,
      // The button now leads somewhere else: its old arrow is gone and a new
      // one appeared.
      _ => inHead ? Change.added : Change.removed,
    };
  }

  static String _keyOf(UiElement element) =>
      '${element.kind.name}/${element.label}';
}
