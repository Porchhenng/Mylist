import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color.fromARGB(255, 42, 56, 62);
  static const Color selectedItem = Color.fromARGB(255, 58, 156, 201);
  static const Color primary = Colors.blueGrey;
  static const Color accent = Colors.green;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color gradientStart = Colors.black;
  static const Color gradientEnd = Colors.transparent;
  static const Color iconColor = Colors.grey;
  
}

class Font {
  // Headline Styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtitle Styles
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Body Text Styles
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button Text Style
  static const TextStyle button = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Caption Text Style
  static const TextStyle caption = TextStyle(
    fontFamily: 'Helvetica',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
