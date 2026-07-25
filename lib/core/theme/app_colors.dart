import 'package:flutter/material.dart';

/// Premium Harmonious Color Palette
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4AD1);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color secondary = Color(0xFF00CEC9);
  static const Color accent = Color(0xFFFF7675);

  // Canvas Paper Colors
  static const Color paperCleanWhite = Color(0xFFFFFFFF);
  static const Color paperCreamSepia = Color(0xFFFBF7EE);
  static const Color paperWarmIvory = Color(0xFFFFFDF5);
  static const Color paperDarkBlueprint = Color(0xFF1E272C);
  static const Color paperGraphiteDark = Color(0xFF181A1B);
  
  // Paper Line & Grid Accent Colors
  static const Color ruleLineBlue = Color(0x334A90E2);
  static const Color ruleLinePinkMargin = Color(0x66FF7675);
  static const Color gridDotColor = Color(0x2B90A4AE);
  static const Color gridDotColorDark = Color(0x2B78909C);

  // Surface & Glassmorphism Colors
  static const Color lightBackground = Color(0xFFF4F6F9);
  static const Color darkBackground = Color(0xFF0F172A);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E293B);

  static const Color lightCardBorder = Color(0xE2E8F0FF);
  static const Color darkCardBorder = Color(0x33334155);

  // Pen Default Palette
  static const List<Color> defaultInkColors = [
    Color(0xFF1E1E1E), // Deep Charcoal
    Color(0xFF2B529A), // Royal Midnight Blue
    Color(0xFFD63031), // Crimson Red
    Color(0xFF00875A), // Emerald Green
    Color(0xFF6C5CE7), // Purple Violet
    Color(0xFFE17055), // Warm Terracotta
    Color(0xFFFDCB6E), // Golden Amber (Highlighter/Pen)
    Color(0xFF55EFC4), // Mint Teal
    Color(0xFFE84393), // Hot Pink
    Color(0xFFFFFFFF), // White
  ];

  static const List<Color> highlighterColors = [
    Color(0x70FFEAA7), // Soft Pastel Yellow
    Color(0x7055EFC4), // Pastel Mint Green
    Color(0x7074B9FF), // Pastel Sky Blue
    Color(0x70A29BFE), // Pastel Lavender
    Color(0x70FF7675), // Pastel Coral Pink
    Color(0x70FFEAA7), // Amber Highlighter
  ];
}
