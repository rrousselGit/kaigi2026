import 'dart:convert';
import 'dart:io';

import 'package:api/src/graphql_schema.dart';
import 'package:api/src/models/book.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

final GraphQL _graphQL = GraphQL(bookSchema);

Response _jsonResponse(Object? body, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(body),
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, OPTIONS',
      'access-control-allow-headers': 'Origin, Content-Type, Accept',
    },
  );
}

Future<Response> _handleGraphQL(Request request) async {
  if (request.method == 'OPTIONS') {
    return Response.ok(
      '',
      headers: {
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, POST, OPTIONS',
        'access-control-allow-headers': 'Origin, Content-Type, Accept',
      },
    );
  }

  String? query;
  Map<String, dynamic>? variables;

  if (request.method == 'POST') {
    final content = await request.readAsString();
    if (content.isNotEmpty) {
      final json = jsonDecode(content) as Map<String, dynamic>;
      query = json['query'] as String?;
      if (json['variables'] != null) {
        variables = json['variables'] as Map<String, dynamic>?;
      }
    }
  } else if (request.method == 'GET') {
    query = request.url.queryParameters['query'];
    final varsParam = request.url.queryParameters['variables'];
    if (varsParam != null && varsParam.isNotEmpty) {
      variables = jsonDecode(varsParam) as Map<String, dynamic>?;
    }
  }

  if (query == null || query.isEmpty) {
    return _jsonResponse({
      'errors': [
        {'message': 'Missing query parameter'},
      ],
    }, statusCode: 400);
  }

  final result = await _graphQL.parseAndExecute(
    query,
    variableValues: variables ?? const {},
  );
  return _jsonResponse({'data': result});
}

Response _handleGetBooks(Request request) {
  final name = request.url.queryParameters['name'];
  final genre = request.url.queryParameters['genre'];

  final filtered = sampleBooks.where((book) {
    if (name != null && name.isNotEmpty) {
      final q = name.toLowerCase();
      final matchTitle = book.title.toLowerCase().contains(q);
      final matchAuthor = book.author.toLowerCase().contains(q);
      if (!matchTitle && !matchAuthor) return false;
    }
    if (genre != null && genre.isNotEmpty) {
      if (book.genre.toLowerCase() != genre.toLowerCase()) return false;
    }
    return true;
  }).toList();

  if (filtered.length == 1 &&
      (filtered.single.id == '3' ||
          filtered.single.title.toLowerCase().contains('architects of mind'))) {
    throw Exception('Failed to fetch Architects of Mind');
  }

  return _jsonResponse(filtered.map((b) => b.toJson()).toList());
}

Response _handleGetBookDetail(Request request, String bookId) {
  if (bookId == '3') {
    throw Exception('Failed to fetch Architects of Mind');
  }
  try {
    final book = sampleBooks.firstWhere((b) => b.id == bookId);
    return _jsonResponse(book.toJson());
  } catch (_) {
    return _jsonResponse({'error': 'Book not found'}, statusCode: 404);
  }
}

void main() async {
  final router = Router()
    ..all('/graphql', _handleGraphQL)
    ..get('/books', _handleGetBooks)
    ..get('/books/<bookId>', _handleGetBookDetail);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    8080,
  );

  // ignore: avoid_print
  print('Server listening on http://${server.address.host}:${server.port}');
}
