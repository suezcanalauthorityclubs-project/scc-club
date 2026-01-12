import 'package:flutter/material.dart';

class AppTheme {
  // Define Baby Blue Color Palette
  static const Color primaryBlue = Color(0xFF89CFF0); 
  static const Color deepBlue = Color(0xFF0077BE);
  static const Color lightBg = Color(0xFFF0F8FF);
  static const Color darkText = Color(0xFF2C3E50);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        primary: deepBlue,
        secondary: primaryBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: deepBlue, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: deepBlue),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}