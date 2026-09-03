import 'dart:async';

import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Query$GetBooks {
  factory Variables$Query$GetBooks({String? name, String? genre}) =>
      Variables$Query$GetBooks._({
        if (name != null) r'name': name,
        if (genre != null) r'genre': genre,
      });

  Variables$Query$GetBooks._(this._$data);

  factory Variables$Query$GetBooks.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    if (data.containsKey('genre')) {
      final l$genre = data['genre'];
      result$data['genre'] = (l$genre as String?);
    }
    return Variables$Query$GetBooks._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get name => (_$data['name'] as String?);

  String? get genre => (_$data['genre'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    if (_$data.containsKey('genre')) {
      final l$genre = genre;
      result$data['genre'] = l$genre;
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetBooks<Variables$Query$GetBooks> get copyWith =>
      CopyWith$Variables$Query$GetBooks(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetBooks ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (_$data.containsKey('genre') != other._$data.containsKey('genre')) {
      return false;
    }
    if (l$genre != lOther$genre) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$genre = genre;
    return Object.hashAll([
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('genre') ? l$genre : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetBooks<TRes> {
  factory CopyWith$Variables$Query$GetBooks(
    Variables$Query$GetBooks instance,
    TRes Function(Variables$Query$GetBooks) then,
  ) = _CopyWithImpl$Variables$Query$GetBooks;

  factory CopyWith$Variables$Query$GetBooks.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetBooks;

  TRes call({String? name, String? genre});
}

class _CopyWithImpl$Variables$Query$GetBooks<TRes>
    implements CopyWith$Variables$Query$GetBooks<TRes> {
  _CopyWithImpl$Variables$Query$GetBooks(this._instance, this._then);

  final Variables$Query$GetBooks _instance;

  final TRes Function(Variables$Query$GetBooks) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? name = _undefined, Object? genre = _undefined}) => _then(
    Variables$Query$GetBooks._({
      ..._instance._$data,
      if (name != _undefined) 'name': (name as String?),
      if (genre != _undefined) 'genre': (genre as String?),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$GetBooks<TRes>
    implements CopyWith$Variables$Query$GetBooks<TRes> {
  _CopyWithStubImpl$Variables$Query$GetBooks(this._res);

  TRes _res;

  call({String? name, String? genre}) => _res;
}

class Query$GetBooks {
  Query$GetBooks({required this.books, this.$__typename = 'Query'});

  factory Query$GetBooks.fromJson(Map<String, dynamic> json) {
    final l$books = json['books'];
    final l$$__typename = json['__typename'];
    return Query$GetBooks(
      books: (l$books as List<dynamic>)
          .map(
            (e) => Query$GetBooks$books.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetBooks$books> books;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$books = books;
    _resultData['books'] = l$books.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$books = books;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$books.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetBooks || runtimeType != other.runtimeType) {
      return false;
    }
    final l$books = books;
    final lOther$books = other.books;
    if (l$books.length != lOther$books.length) {
      return false;
    }
    for (int i = 0; i < l$books.length; i++) {
      final l$books$entry = l$books[i];
      final lOther$books$entry = lOther$books[i];
      if (l$books$entry != lOther$books$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetBooks on Query$GetBooks {
  CopyWith$Query$GetBooks<Query$GetBooks> get copyWith =>
      CopyWith$Query$GetBooks(this, (i) => i);
}

abstract class CopyWith$Query$GetBooks<TRes> {
  factory CopyWith$Query$GetBooks(
    Query$GetBooks instance,
    TRes Function(Query$GetBooks) then,
  ) = _CopyWithImpl$Query$GetBooks;

  factory CopyWith$Query$GetBooks.stub(TRes res) =
      _CopyWithStubImpl$Query$GetBooks;

  TRes call({List<Query$GetBooks$books>? books, String? $__typename});
  TRes books(
    Iterable<Query$GetBooks$books> Function(
      Iterable<CopyWith$Query$GetBooks$books<Query$GetBooks$books>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$GetBooks<TRes>
    implements CopyWith$Query$GetBooks<TRes> {
  _CopyWithImpl$Query$GetBooks(this._instance, this._then);

  final Query$GetBooks _instance;

  final TRes Function(Query$GetBooks) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? books = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$GetBooks(
          books: books == _undefined || books == null
              ? _instance.books
              : (books as List<Query$GetBooks$books>),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );

  TRes books(
    Iterable<Query$GetBooks$books> Function(
      Iterable<CopyWith$Query$GetBooks$books<Query$GetBooks$books>>,
    )
    _fn,
  ) => call(
    books: _fn(
      _instance.books.map((e) => CopyWith$Query$GetBooks$books(e, (i) => i)),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$GetBooks<TRes>
    implements CopyWith$Query$GetBooks<TRes> {
  _CopyWithStubImpl$Query$GetBooks(this._res);

  TRes _res;

  call({List<Query$GetBooks$books>? books, String? $__typename}) => _res;

  books(_fn) => _res;
}

const documentNodeQueryGetBooks = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'GetBooks'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'name')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'genre')),
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'books'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'name'),
                value: VariableNode(name: NameNode(value: 'name')),
              ),
              ArgumentNode(
                name: NameNode(value: 'genre'),
                value: VariableNode(name: NameNode(value: 'genre')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'id'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'title'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'author'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'description'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'synopsis'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'rating'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'genre'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'pages'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'publishYear'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
  ],
);
Query$GetBooks _parserFn$Query$GetBooks(Map<String, dynamic> data) =>
    Query$GetBooks.fromJson(data);
typedef OnQueryComplete$Query$GetBooks =
    FutureOr<void> Function(Map<String, dynamic>?, Query$GetBooks?);

class Options$Query$GetBooks extends graphql.QueryOptions<Query$GetBooks> {
  Options$Query$GetBooks({
    String? operationName,
    Variables$Query$GetBooks? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetBooks? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetBooks? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$GetBooks(data),
               ),
         onError: onError,
         document: documentNodeQueryGetBooks,
         parserFn: _parserFn$Query$GetBooks,
       );

  final OnQueryComplete$Query$GetBooks? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$GetBooks
    extends graphql.WatchQueryOptions<Query$GetBooks> {
  WatchOptions$Query$GetBooks({
    String? operationName,
    Variables$Query$GetBooks? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetBooks? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryGetBooks,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$GetBooks,
       );
}

class FetchMoreOptions$Query$GetBooks extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetBooks({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetBooks? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryGetBooks,
       );
}

extension ClientExtension$Query$GetBooks on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetBooks>> query$GetBooks([
    Options$Query$GetBooks? options,
  ]) async => await this.query(options ?? Options$Query$GetBooks());

  graphql.ObservableQuery<Query$GetBooks> watchQuery$GetBooks([
    WatchOptions$Query$GetBooks? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$GetBooks());

  void writeQuery$GetBooks({
    required Query$GetBooks data,
    Variables$Query$GetBooks? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryGetBooks),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$GetBooks? readQuery$GetBooks({
    Variables$Query$GetBooks? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetBooks),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetBooks.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetBooks> useQuery$GetBooks([
  Options$Query$GetBooks? options,
]) => graphql_flutter.useQuery(options ?? Options$Query$GetBooks());
graphql.ObservableQuery<Query$GetBooks> useWatchQuery$GetBooks([
  WatchOptions$Query$GetBooks? options,
]) => graphql_flutter.useWatchQuery(options ?? WatchOptions$Query$GetBooks());

class Query$GetBooks$Widget extends graphql_flutter.Query<Query$GetBooks> {
  Query$GetBooks$Widget({
    widgets.Key? key,
    Options$Query$GetBooks? options,
    required graphql_flutter.QueryBuilder<Query$GetBooks> builder,
  }) : super(
         key: key,
         options: options ?? Options$Query$GetBooks(),
         builder: builder,
       );
}

class Query$GetBooks$books {
  Query$GetBooks$books({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.synopsis,
    required this.rating,
    required this.genre,
    required this.pages,
    required this.publishYear,
    this.$__typename = 'Book',
  });

  factory Query$GetBooks$books.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$author = json['author'];
    final l$description = json['description'];
    final l$synopsis = json['synopsis'];
    final l$rating = json['rating'];
    final l$genre = json['genre'];
    final l$pages = json['pages'];
    final l$publishYear = json['publishYear'];
    final l$$__typename = json['__typename'];
    return Query$GetBooks$books(
      id: (l$id as String),
      title: (l$title as String),
      author: (l$author as String),
      description: (l$description as String),
      synopsis: (l$synopsis as String),
      rating: (l$rating as num).toDouble(),
      genre: (l$genre as String),
      pages: (l$pages as int),
      publishYear: (l$publishYear as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String title;

  final String author;

  final String description;

  final String synopsis;

  final double rating;

  final String genre;

  final int pages;

  final int publishYear;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$author = author;
    _resultData['author'] = l$author;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$synopsis = synopsis;
    _resultData['synopsis'] = l$synopsis;
    final l$rating = rating;
    _resultData['rating'] = l$rating;
    final l$genre = genre;
    _resultData['genre'] = l$genre;
    final l$pages = pages;
    _resultData['pages'] = l$pages;
    final l$publishYear = publishYear;
    _resultData['publishYear'] = l$publishYear;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$author = author;
    final l$description = description;
    final l$synopsis = synopsis;
    final l$rating = rating;
    final l$genre = genre;
    final l$pages = pages;
    final l$publishYear = publishYear;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$author,
      l$description,
      l$synopsis,
      l$rating,
      l$genre,
      l$pages,
      l$publishYear,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetBooks$books || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (l$author != lOther$author) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$synopsis = synopsis;
    final lOther$synopsis = other.synopsis;
    if (l$synopsis != lOther$synopsis) {
      return false;
    }
    final l$rating = rating;
    final lOther$rating = other.rating;
    if (l$rating != lOther$rating) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (l$genre != lOther$genre) {
      return false;
    }
    final l$pages = pages;
    final lOther$pages = other.pages;
    if (l$pages != lOther$pages) {
      return false;
    }
    final l$publishYear = publishYear;
    final lOther$publishYear = other.publishYear;
    if (l$publishYear != lOther$publishYear) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetBooks$books on Query$GetBooks$books {
  CopyWith$Query$GetBooks$books<Query$GetBooks$books> get copyWith =>
      CopyWith$Query$GetBooks$books(this, (i) => i);
}

abstract class CopyWith$Query$GetBooks$books<TRes> {
  factory CopyWith$Query$GetBooks$books(
    Query$GetBooks$books instance,
    TRes Function(Query$GetBooks$books) then,
  ) = _CopyWithImpl$Query$GetBooks$books;

  factory CopyWith$Query$GetBooks$books.stub(TRes res) =
      _CopyWithStubImpl$Query$GetBooks$books;

  TRes call({
    String? id,
    String? title,
    String? author,
    String? description,
    String? synopsis,
    double? rating,
    String? genre,
    int? pages,
    int? publishYear,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetBooks$books<TRes>
    implements CopyWith$Query$GetBooks$books<TRes> {
  _CopyWithImpl$Query$GetBooks$books(this._instance, this._then);

  final Query$GetBooks$books _instance;

  final TRes Function(Query$GetBooks$books) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? author = _undefined,
    Object? description = _undefined,
    Object? synopsis = _undefined,
    Object? rating = _undefined,
    Object? genre = _undefined,
    Object? pages = _undefined,
    Object? publishYear = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetBooks$books(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined || title == null
          ? _instance.title
          : (title as String),
      author: author == _undefined || author == null
          ? _instance.author
          : (author as String),
      description: description == _undefined || description == null
          ? _instance.description
          : (description as String),
      synopsis: synopsis == _undefined || synopsis == null
          ? _instance.synopsis
          : (synopsis as String),
      rating: rating == _undefined || rating == null
          ? _instance.rating
          : (rating as double),
      genre: genre == _undefined || genre == null
          ? _instance.genre
          : (genre as String),
      pages: pages == _undefined || pages == null
          ? _instance.pages
          : (pages as int),
      publishYear: publishYear == _undefined || publishYear == null
          ? _instance.publishYear
          : (publishYear as int),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$GetBooks$books<TRes>
    implements CopyWith$Query$GetBooks$books<TRes> {
  _CopyWithStubImpl$Query$GetBooks$books(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    String? author,
    String? description,
    String? synopsis,
    double? rating,
    String? genre,
    int? pages,
    int? publishYear,
    String? $__typename,
  }) => _res;
}

class Variables$Query$GetBook {
  factory Variables$Query$GetBook({required String id}) =>
      Variables$Query$GetBook._({r'id': id});

  Variables$Query$GetBook._(this._$data);

  factory Variables$Query$GetBook.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$GetBook._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetBook<Variables$Query$GetBook> get copyWith =>
      CopyWith$Variables$Query$GetBook(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetBook || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$GetBook<TRes> {
  factory CopyWith$Variables$Query$GetBook(
    Variables$Query$GetBook instance,
    TRes Function(Variables$Query$GetBook) then,
  ) = _CopyWithImpl$Variables$Query$GetBook;

  factory CopyWith$Variables$Query$GetBook.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetBook;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$GetBook<TRes>
    implements CopyWith$Variables$Query$GetBook<TRes> {
  _CopyWithImpl$Variables$Query$GetBook(this._instance, this._then);

  final Variables$Query$GetBook _instance;

  final TRes Function(Variables$Query$GetBook) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$GetBook._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$GetBook<TRes>
    implements CopyWith$Variables$Query$GetBook<TRes> {
  _CopyWithStubImpl$Variables$Query$GetBook(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$GetBook {
  Query$GetBook({this.book, this.$__typename = 'Query'});

  factory Query$GetBook.fromJson(Map<String, dynamic> json) {
    final l$book = json['book'];
    final l$$__typename = json['__typename'];
    return Query$GetBook(
      book: l$book == null
          ? null
          : Query$GetBook$book.fromJson((l$book as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetBook$book? book;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$book = book;
    _resultData['book'] = l$book?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$book = book;
    final l$$__typename = $__typename;
    return Object.hashAll([l$book, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetBook || runtimeType != other.runtimeType) {
      return false;
    }
    final l$book = book;
    final lOther$book = other.book;
    if (l$book != lOther$book) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetBook on Query$GetBook {
  CopyWith$Query$GetBook<Query$GetBook> get copyWith =>
      CopyWith$Query$GetBook(this, (i) => i);
}

abstract class CopyWith$Query$GetBook<TRes> {
  factory CopyWith$Query$GetBook(
    Query$GetBook instance,
    TRes Function(Query$GetBook) then,
  ) = _CopyWithImpl$Query$GetBook;

  factory CopyWith$Query$GetBook.stub(TRes res) =
      _CopyWithStubImpl$Query$GetBook;

  TRes call({Query$GetBook$book? book, String? $__typename});
  CopyWith$Query$GetBook$book<TRes> get book;
}

class _CopyWithImpl$Query$GetBook<TRes>
    implements CopyWith$Query$GetBook<TRes> {
  _CopyWithImpl$Query$GetBook(this._instance, this._then);

  final Query$GetBook _instance;

  final TRes Function(Query$GetBook) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? book = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Query$GetBook(
          book: book == _undefined
              ? _instance.book
              : (book as Query$GetBook$book?),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );

  CopyWith$Query$GetBook$book<TRes> get book {
    final local$book = _instance.book;
    return local$book == null
        ? CopyWith$Query$GetBook$book.stub(_then(_instance))
        : CopyWith$Query$GetBook$book(local$book, (e) => call(book: e));
  }
}

class _CopyWithStubImpl$Query$GetBook<TRes>
    implements CopyWith$Query$GetBook<TRes> {
  _CopyWithStubImpl$Query$GetBook(this._res);

  TRes _res;

  call({Query$GetBook$book? book, String? $__typename}) => _res;

  CopyWith$Query$GetBook$book<TRes> get book =>
      CopyWith$Query$GetBook$book.stub(_res);
}

const documentNodeQueryGetBook = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'GetBook'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'book'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'id'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'title'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'author'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'description'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'synopsis'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'rating'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'genre'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'pages'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'publishYear'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
  ],
);
Query$GetBook _parserFn$Query$GetBook(Map<String, dynamic> data) =>
    Query$GetBook.fromJson(data);
typedef OnQueryComplete$Query$GetBook =
    FutureOr<void> Function(Map<String, dynamic>?, Query$GetBook?);

class Options$Query$GetBook extends graphql.QueryOptions<Query$GetBook> {
  Options$Query$GetBook({
    String? operationName,
    required Variables$Query$GetBook variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetBook? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetBook? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$GetBook(data),
               ),
         onError: onError,
         document: documentNodeQueryGetBook,
         parserFn: _parserFn$Query$GetBook,
       );

  final OnQueryComplete$Query$GetBook? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$GetBook
    extends graphql.WatchQueryOptions<Query$GetBook> {
  WatchOptions$Query$GetBook({
    String? operationName,
    required Variables$Query$GetBook variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetBook? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryGetBook,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$GetBook,
       );
}

class FetchMoreOptions$Query$GetBook extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetBook({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetBook variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryGetBook,
       );
}

extension ClientExtension$Query$GetBook on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetBook>> query$GetBook(
    Options$Query$GetBook options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$GetBook> watchQuery$GetBook(
    WatchOptions$Query$GetBook options,
  ) => this.watchQuery(options);

  void writeQuery$GetBook({
    required Query$GetBook data,
    required Variables$Query$GetBook variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryGetBook),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$GetBook? readQuery$GetBook({
    required Variables$Query$GetBook variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetBook),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetBook.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetBook> useQuery$GetBook(
  Options$Query$GetBook options,
) => graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetBook> useWatchQuery$GetBook(
  WatchOptions$Query$GetBook options,
) => graphql_flutter.useWatchQuery(options);

class Query$GetBook$Widget extends graphql_flutter.Query<Query$GetBook> {
  Query$GetBook$Widget({
    widgets.Key? key,
    required Options$Query$GetBook options,
    required graphql_flutter.QueryBuilder<Query$GetBook> builder,
  }) : super(key: key, options: options, builder: builder);
}

class Query$GetBook$book {
  Query$GetBook$book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.synopsis,
    required this.rating,
    required this.genre,
    required this.pages,
    required this.publishYear,
    this.$__typename = 'Book',
  });

  factory Query$GetBook$book.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$author = json['author'];
    final l$description = json['description'];
    final l$synopsis = json['synopsis'];
    final l$rating = json['rating'];
    final l$genre = json['genre'];
    final l$pages = json['pages'];
    final l$publishYear = json['publishYear'];
    final l$$__typename = json['__typename'];
    return Query$GetBook$book(
      id: (l$id as String),
      title: (l$title as String),
      author: (l$author as String),
      description: (l$description as String),
      synopsis: (l$synopsis as String),
      rating: (l$rating as num).toDouble(),
      genre: (l$genre as String),
      pages: (l$pages as int),
      publishYear: (l$publishYear as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String title;

  final String author;

  final String description;

  final String synopsis;

  final double rating;

  final String genre;

  final int pages;

  final int publishYear;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$author = author;
    _resultData['author'] = l$author;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$synopsis = synopsis;
    _resultData['synopsis'] = l$synopsis;
    final l$rating = rating;
    _resultData['rating'] = l$rating;
    final l$genre = genre;
    _resultData['genre'] = l$genre;
    final l$pages = pages;
    _resultData['pages'] = l$pages;
    final l$publishYear = publishYear;
    _resultData['publishYear'] = l$publishYear;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$author = author;
    final l$description = description;
    final l$synopsis = synopsis;
    final l$rating = rating;
    final l$genre = genre;
    final l$pages = pages;
    final l$publishYear = publishYear;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$author,
      l$description,
      l$synopsis,
      l$rating,
      l$genre,
      l$pages,
      l$publishYear,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetBook$book || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$author = author;
    final lOther$author = other.author;
    if (l$author != lOther$author) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$synopsis = synopsis;
    final lOther$synopsis = other.synopsis;
    if (l$synopsis != lOther$synopsis) {
      return false;
    }
    final l$rating = rating;
    final lOther$rating = other.rating;
    if (l$rating != lOther$rating) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (l$genre != lOther$genre) {
      return false;
    }
    final l$pages = pages;
    final lOther$pages = other.pages;
    if (l$pages != lOther$pages) {
      return false;
    }
    final l$publishYear = publishYear;
    final lOther$publishYear = other.publishYear;
    if (l$publishYear != lOther$publishYear) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetBook$book on Query$GetBook$book {
  CopyWith$Query$GetBook$book<Query$GetBook$book> get copyWith =>
      CopyWith$Query$GetBook$book(this, (i) => i);
}

abstract class CopyWith$Query$GetBook$book<TRes> {
  factory CopyWith$Query$GetBook$book(
    Query$GetBook$book instance,
    TRes Function(Query$GetBook$book) then,
  ) = _CopyWithImpl$Query$GetBook$book;

  factory CopyWith$Query$GetBook$book.stub(TRes res) =
      _CopyWithStubImpl$Query$GetBook$book;

  TRes call({
    String? id,
    String? title,
    String? author,
    String? description,
    String? synopsis,
    double? rating,
    String? genre,
    int? pages,
    int? publishYear,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetBook$book<TRes>
    implements CopyWith$Query$GetBook$book<TRes> {
  _CopyWithImpl$Query$GetBook$book(this._instance, this._then);

  final Query$GetBook$book _instance;

  final TRes Function(Query$GetBook$book) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? author = _undefined,
    Object? description = _undefined,
    Object? synopsis = _undefined,
    Object? rating = _undefined,
    Object? genre = _undefined,
    Object? pages = _undefined,
    Object? publishYear = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$GetBook$book(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      title: title == _undefined || title == null
          ? _instance.title
          : (title as String),
      author: author == _undefined || author == null
          ? _instance.author
          : (author as String),
      description: description == _undefined || description == null
          ? _instance.description
          : (description as String),
      synopsis: synopsis == _undefined || synopsis == null
          ? _instance.synopsis
          : (synopsis as String),
      rating: rating == _undefined || rating == null
          ? _instance.rating
          : (rating as double),
      genre: genre == _undefined || genre == null
          ? _instance.genre
          : (genre as String),
      pages: pages == _undefined || pages == null
          ? _instance.pages
          : (pages as int),
      publishYear: publishYear == _undefined || publishYear == null
          ? _instance.publishYear
          : (publishYear as int),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Query$GetBook$book<TRes>
    implements CopyWith$Query$GetBook$book<TRes> {
  _CopyWithStubImpl$Query$GetBook$book(this._res);

  TRes _res;

  call({
    String? id,
    String? title,
    String? author,
    String? description,
    String? synopsis,
    double? rating,
    String? genre,
    int? pages,
    int? publishYear,
    String? $__typename,
  }) => _res;
}
