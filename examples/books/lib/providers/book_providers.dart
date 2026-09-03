import 'package:api_schema/api_schema.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/graphql_service.dart';

/// Provider for [GraphQLService] instance.
final graphQLServiceProvider = Provider<GraphQLService>((ref) {
  return GraphQLService();
}, name: 'graphQLServiceProvider');

/// Notifier for managing search query filter state.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Notifier for managing selected category filter state.
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void setCategory(String category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
      SelectedCategoryNotifier.new,
    );

/// Provider for reactive list of books based on current filter criteria.
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final service = ref.watch(graphQLServiceProvider);

  return service.fetchBooks(
    name: searchQuery.isEmpty ? null : searchQuery,
    genre: selectedCategory == 'All' ? null : selectedCategory,
  );
}, name: 'booksProvider');

/// Family provider for fetching detailed information about a single book by ID.
final bookDetailProvider = FutureProvider.family<Query$GetBook$book?, String>((
  ref,
  id,
) async {
  final service = ref.watch(graphQLServiceProvider);
  return service.fetchBook(id);
}, name: 'bookDetailProvider');

/// Notifier for managing favorite book IDs reactively.
class FavoriteBookIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void add(String id) {
    if (!state.contains(id)) {
      state = {...state, id};
    }
  }

  void remove(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    }
  }
}

final favoriteBookIdsProvider =
    NotifierProvider<FavoriteBookIdsNotifier, Set<String>>(
      FavoriteBookIdsNotifier.new,
    );
