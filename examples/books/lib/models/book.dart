import 'package:api_schema/api_schema.dart';
import 'package:flutter/material.dart';

typedef Book = Query$GetBooks$books;

extension QueryGetBookToBook on Query$GetBook$book {
  Book toBook() {
    return Book(
      id: id,
      title: title,
      author: author,
      description: description,
      synopsis: synopsis,
      rating: rating,
      genre: genre,
      pages: pages,
      publishYear: publishYear,
    );
  }
}


extension BookVisuals on Book {
  List<Color> get gradientColors {
    switch (genre.toLowerCase()) {
      case 'sci-fi':
        if (id == '6') {
          return const [Color(0xFF831843), Color(0xFFDB2777)];
        }
        return const [Color(0xFF1E1B4B), Color(0xFF4338CA)];
      case 'fantasy':
        return const [Color(0xFF064E3B), Color(0xFF059669)];
      case 'technology':
        return const [Color(0xFF701A75), Color(0xFFC026D3)];
      case 'mystery':
        return const [Color(0xFF312E81), Color(0xFF1E293B)];
      case 'fiction':
        return const [Color(0xFF78350F), Color(0xFFD97706)];
      case 'cyberpunk':
        return const [Color(0xFF4C1D95), Color(0xFF06B6D4)];
      case 'thriller':
        return const [Color(0xFF881337), Color(0xFFE11D48)];
      case 'romance':
        return const [Color(0xFF831843), Color(0xFFF43F5E)];
      case 'history':
        return const [Color(0xFF451A03), Color(0xFFB45309)];
      case 'philosophy':
        return const [Color(0xFF14532D), Color(0xFF15803D)];
      case 'non-fiction':
        return const [Color(0xFF1E293B), Color(0xFF0284C7)];
      case 'horror':
        return const [Color(0xFF3F0712), Color(0xFF991B1B)];
      case 'biography':
        return const [Color(0xFF365314), Color(0xFF65A30D)];
      default:
        return const [Color(0xFF1F2937), Color(0xFF4B5563)];
    }
  }

  Color get accentColor {
    switch (genre.toLowerCase()) {
      case 'sci-fi':
        if (id == '6') return const Color(0xFFF472B6);
        return const Color(0xFF818CF8);
      case 'fantasy':
        return const Color(0xFF34D399);
      case 'technology':
        return const Color(0xFFF0ABFC);
      case 'mystery':
        return const Color(0xFF94A3B8);
      case 'fiction':
        return const Color(0xFFFBBF24);
      case 'cyberpunk':
        return const Color(0xFF22D3EE);
      case 'thriller':
        return const Color(0xFFFB7185);
      case 'romance':
        return const Color(0xFFFDA4AF);
      case 'history':
        return const Color(0xFFFDE047);
      case 'philosophy':
        return const Color(0xFF4ADE80);
      case 'non-fiction':
        return const Color(0xFF38BDF8);
      case 'horror':
        return const Color(0xFFF87171);
      case 'biography':
        return const Color(0xFFA3E635);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData get coverIcon {
    switch (genre.toLowerCase()) {
      case 'sci-fi':
        if (id == '6') return Icons.blur_on;
        return Icons.auto_awesome;
      case 'fantasy':
        return Icons.fort;
      case 'technology':
        return Icons.psychology;
      case 'mystery':
        return Icons.search;
      case 'fiction':
        return Icons.nature_people;
      case 'cyberpunk':
        return Icons.memory;
      case 'thriller':
        return Icons.flash_on;
      case 'romance':
        return Icons.favorite;
      case 'history':
        return Icons.account_balance;
      case 'philosophy':
        return Icons.lightbulb;
      case 'non-fiction':
        return Icons.import_contacts;
      case 'horror':
        return Icons.nights_stay;
      case 'biography':
        return Icons.person_pin;
      default:
        return Icons.menu_book;
    }
  }
}
