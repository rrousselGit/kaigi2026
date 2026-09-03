import 'package:api_schema/api_schema.dart';
import 'package:flutter/material.dart';

typedef Book = Query$GetBooks$books;

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
      default:
        return Icons.menu_book;
    }
  }
}
