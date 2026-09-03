// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: json['id'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  description: json['description'] as String,
  synopsis: json['synopsis'] as String,
  rating: (json['rating'] as num).toDouble(),
  genre: json['genre'] as String,
  pages: (json['pages'] as num).toInt(),
  publishYear: (json['publishYear'] as num).toInt(),
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'description': instance.description,
  'synopsis': instance.synopsis,
  'rating': instance.rating,
  'genre': instance.genre,
  'pages': instance.pages,
  'publishYear': instance.publishYear,
};
