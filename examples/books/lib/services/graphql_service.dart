import 'dart:convert';
import 'dart:developer' as developer;

import 'package:api_schema/api_schema.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../env/env.dart';
import '../models/book.dart';
import 'logger_service.dart';
import 'logging_http_client.dart';

class GraphQLService {
  final GraphQLClient client;

  GraphQLService({GraphQLClient? client})
    : client =
          client ??
          GraphQLClient(
            link: HttpLink(
              '${Env.apiHost}/graphql',
              httpClient: LoggingHttpClient(),
            ),
            cache: GraphQLCache(store: InMemoryStore()),
          ) {
    _registerExtension();
  }

  void _registerExtension() {
    try {
      developer.registerExtension('ext.books.gql', (method, parameters) async {
        final query = parameters['query'];
        if (query == null || query.trim().isEmpty) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing required parameter: query',
          );
        }

        Map<String, dynamic>? variables;
        if (parameters.containsKey('variables') &&
            parameters['variables'] != null) {
          try {
            variables =
                jsonDecode(parameters['variables']!) as Map<String, dynamic>?;
          } catch (e) {
            return developer.ServiceExtensionResponse.error(
              developer.ServiceExtensionResponse.invalidParams,
              'Invalid JSON for variables: $e',
            );
          }
        }

        try {
          final options = QueryOptions(
            document: gql(query),
            variables: variables ?? const {},
            fetchPolicy: FetchPolicy.networkOnly,
          );
          final result = await client.query(options);

          if (result.hasException) {
            final errors =
                result.exception?.graphqlErrors
                    .map((e) => e.message)
                    .toList() ??
                [result.exception.toString()];
            return developer.ServiceExtensionResponse.result(
              jsonEncode({'data': result.data, 'errors': errors}),
            );
          }

          return developer.ServiceExtensionResponse.result(
            jsonEncode({'data': result.data}),
          );
        } catch (e) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.extensionError,
            'Error executing GraphQL query: $e',
          );
        }
      });
    } catch (_) {
      // Ignore if extension is already registered
    }
  }

  Future<List<Book>> fetchBooks({String? name, String? genre}) async {
    final nameVar = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : null;
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
      AppLogger.instance.logException(
        result.exception!,
        null,
        'GraphQL GetBooks Exception',
      );
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
      AppLogger.instance.logException(
        result.exception!,
        null,
        'GraphQL GetBook Exception',
      );
      throw result.exception!;
    }

    return result.parsedData?.book;
  }
}
