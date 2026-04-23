import 'package:flutter/material.dart';

class AppTheme {
  static const Color pureBlack = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color borderCol = Color(0xFF2A2A2A);
  
  static const Color orangeAccent = Color(0xFFE85D1E);
  static const Color blueAccent = Color(0xFF3B82F6); // Added from Doctor app
  static const Color successGreen = Color(0xFF4ADE80);
  static const Color warningOrange = Color(0xFFFB923C);
  static const Color dangerRed = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,
      primaryColor: orangeAccent,
      colorScheme: const ColorScheme.dark(
        primary: orangeAccent,
        surface: darkSurface,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderCol, width: 0.5),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFF666666)), 
      ),
      useMaterial3: true,
    );
  }
}
