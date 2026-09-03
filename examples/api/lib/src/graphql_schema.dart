import 'package:graphql_schema2/graphql_schema2.dart';
import 'models/book.dart';

class NullableGraphQLStringType extends GraphQLStringType {
  NullableGraphQLStringType() : super();

  @override
  ValidationResult<String> validate(String key, dynamic input) {
    if (input == null) {
      return super.validate(key, '');
    }
    return super.validate(key, input);
  }

  @override
  String deserialize(dynamic serialized) {
    if (serialized == null) return '';
    return super.deserialize(serialized as String);
  }
}

final nullableGraphQLString = NullableGraphQLStringType();

final GraphQLObjectType bookType = objectType(
  'Book',
  description: 'A book entity',
  fields: [
    field('id', graphQLString.nonNullable()),
    field('title', graphQLString.nonNullable()),
    field('author', graphQLString.nonNullable()),
    field('description', graphQLString.nonNullable()),
    field('synopsis', graphQLString.nonNullable()),
    field('rating', graphQLFloat.nonNullable()),
    field('genre', graphQLString.nonNullable()),
    field('pages', graphQLInt.nonNullable()),
    field('publishYear', graphQLInt.nonNullable()),
  ],
);

final GraphQLSchema bookSchema = GraphQLSchema(
  queryType: objectType(
    'Query',
    fields: [
      field(
        'books',
        listOf(bookType.nonNullable()).nonNullable(),
        inputs: [
          GraphQLFieldInput('name', nullableGraphQLString, defaultsToNull: true),
          GraphQLFieldInput('genre', nullableGraphQLString, defaultsToNull: true),
        ],
        resolve: (_, args) {
          final name = args['name'] as String?;
          final genre = args['genre'] as String?;

          return sampleBooks.where((book) {
            if (name != null && name.isNotEmpty) {
              final query = name.toLowerCase();
              final matchesTitle = book.title.toLowerCase().contains(query);
              final matchesAuthor = book.author.toLowerCase().contains(query);
              if (!matchesTitle && !matchesAuthor) return false;
            }
            if (genre != null && genre.isNotEmpty) {
              if (book.genre.toLowerCase() != genre.toLowerCase()) return false;
            }
            return true;
          }).map((b) => b.toJson()).toList();
        },
      ),
      field(
        'book',
        bookType,
        inputs: [
          GraphQLFieldInput('id', graphQLString.nonNullable()),
        ],
        resolve: (_, args) {
          final id = args['id'] as String;
          try {
            final book = sampleBooks.firstWhere((b) => b.id == id);
            return book.toJson();
          } catch (_) {
            return null;
          }
        },
      ),
    ],
  ),
);
