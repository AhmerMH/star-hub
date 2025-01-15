import 'package:flutter/material.dart';

class AppStyles {
  static final Map<String, Map<String, Color>> themes = {
    'theme1': {
      'background': const Color(0xFFFFFFFF),
      'card': const Color(0xFFF5F5F5),
      'primary': const Color(0xFF2196F3),
      'secondary': const Color(0xFF4CAF50),
      'accent': const Color(0xFFFFA726),
      'text': const Color(0xFF212121),
      'subtext': const Color(0xFF757575),
      'border': const Color(0xFFE0E0E0),
      'success': const Color(0xFF4CAF50),
      'warning': const Color(0xFFFFB74D),
      'error': const Color(0xFFE53935),
      'info': const Color(0xFF2196F3),
    },
    'theme2': {
      'background': const Color(0xFF121212),
      'card': const Color(0xFF1E1E1E),
      'primary': const Color(0xFF64B5F6),
      'secondary': const Color(0xFF81C784),
      'accent': const Color(0xFFFFB74D),
      'text': const Color(0xFFFFFFFF),
      'subtext': const Color(0xFFBDBDBD),
      'border': const Color(0xFF424242),
      'success': const Color(0xFF81C784),
      'warning': const Color(0xFFFFB74D),
      'error': const Color(0xFFE57373),
      'info': const Color(0xFF64B5F6),
    },
  };

  static Color getColor(String themeName, String colorName) {
    return themes[themeName]?[colorName] ?? themes['light']!['primary']!;
  }

  // Usage: AppStyles.getColor('theme', 'colorKey')
}
