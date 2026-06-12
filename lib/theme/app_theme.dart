import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF9F4A), // Lumen оранжевый
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    backgroundColor: const Color(0xFF0A0A0A),
    cardColor: const Color(0xFF1C1C1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFFF9F4A)),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF9F4A),
      secondary: Color(0xFFFF9F4A),
      surface: Color(0xFF1C1C1E),
      background: Color(0xFF0A0A0A),
    ),
  );
}