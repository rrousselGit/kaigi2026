import 'package:api_schema/api_schema.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../env/env.dart';
import '../models/book.dart';

class GraphQLService {
  final GraphQLClient client;

  GraphQLService({GraphQLClient? client})
      : client = client ??
            GraphQLClient(
              link: HttpLink('${Env.apiHost}/graphql'),
              cache: GraphQLCache(store: InMemoryStore()),
            );

  Future<List<Book>> fetchBooks({String? name, String? genre}) async {
    final nameVar =
        (name != null && name.trim().isNotEmpty) ? name.trim() : null;
    final genreVar =
        (genre != null && genre.trim().isNotEmpty && genre != 'All')
            ? genre.trim()
            : null;

    final options = Options$Query$GetBooks(
      variables: Variables$Query$GetBooks(name: nameVar, genre: genreVar),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query$GetBooks(options);

    if (result.hasException) {
      throw result.exception!;
    }

    return result.parsedData?.books ?? [];
  }

  Future<Query$GetBook$book?> fetchBook(String id) async {
    final options = Options$Query$GetBook(
      variables: Variables$Query$GetBook(id: id),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query$GetBook(options);

    if (result.hasException) {
      throw result.exception!;
    }

    return result.parsedData?.book;
  }
}
