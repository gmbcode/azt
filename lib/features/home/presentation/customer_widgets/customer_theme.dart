import 'package:flutter/material.dart';

class CustomerTheme {
  static final Color _primary = const Color(0xFF4E80EE); // Electric Blue
  static final Color _background = const Color(0xFF121212); // Void Black
  static const Color _surface = Color(0xFF1E1E1E); // Card Surface
  static const Color _surfaceHighlight = Color(0xFF2C2C2C); // Inputs

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primary, 
      scaffoldBackgroundColor: _background,

      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: Colors.white, 
        surface: _surface,
        onPrimary: Colors.white, 
        onSecondary: Colors.white,
        tertiary: _surfaceHighlight, // Used for search bars
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: _background, 
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: _surface, 
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // High rounded corners
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary, 
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIconColor: Colors.grey[500],
      ),
    );
  }
}