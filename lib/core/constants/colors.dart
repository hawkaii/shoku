import 'package:flutter/material.dart';

// Neobrutalism Color Palette
class NeuColors {
  // Primary Colors (Bright & Bold)
  static const neuYellow = Color(0xFFFFD803);
  static const neuPink = Color(0xFFFF6B9D);
  static const neuMint = Color(0xFF7BFFB2);
  static const neuLavender = Color(0xFFECB5D8);
  static const neuSkyBlue = Color(0xFF89CFF0);
  static const neuCoral = Color(0xFFFF7F50);

  // Backgrounds
  static const neuWhite = Color(0xFFFFFFF5);
  static const neuCream = Color(0xFFFFF8DC);

  // Text & Borders
  static const neuBlack = Colors.black;

  // Category Colors (Shopping Lists)
  static const categoryProduce = neuMint;
  static const categoryProtein = neuPink;
  static const categoryDairy = neuSkyBlue;
  static const categorySpices = neuYellow;
  static const categoryOther = neuLavender;

  // Get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return categoryProduce;
      case 'protein':
        return categoryProtein;
      case 'dairy':
        return categoryDairy;
      case 'spices':
        return categorySpices;
      default:
        return categoryOther;
    }
  }
}
