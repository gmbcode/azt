import 'package:flutter/material.dart';

class AppTheme {
  // ----------------------------------------------------------
  // LIGHT THEME (Professional Blue & Teal)
  // ----------------------------------------------------------
  static const Color _lightPrimary = Color(0xFF1A237E); // Deep Indigo
  static const Color _lightAccent = Color(0xFF00BFA5);  // Teal
  static const Color _lightBackground = Color(0xFFF4F6F8);
  static const Color _lightSurface = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightPrimary,
      scaffoldBackgroundColor: _lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightAccent,
        surface: _lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),

      // Sidebar & AppBar will use this color
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // DARK THEME (Based on your existing dark_mode.dart)
  // ----------------------------------------------------------
  // We map your existing specific colors to the new UI structure
  
  static final Color _darkPrimary = Colors.grey.shade500;       // Your 'primary'
  static final Color _darkBackground = Colors.grey.shade900;    // Your 'scaffold'
  static const Color _darkSurface = Color.fromARGB(255, 39, 39, 39); // Your 'secondary'
  static const Color _darkSidebar = Color.fromARGB(255, 25, 25, 25); // Your 'tertiary'
  static final Color _darkAccent = Colors.grey.shade300;        // Your 'inversePrimary'

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkPrimary, 
      scaffoldBackgroundColor: _darkBackground,

      colorScheme: ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkAccent, // Used for buttons/highlights
        surface: _darkSurface,
        background: _darkBackground,
        onPrimary: Colors.black, 
        onSecondary: Colors.black,
      ),

      // Sidebar & AppBar will use this color (Dark Grey)
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSidebar, 
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: _darkSurface, // Dark Grey Cards
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withOpacity(0.05)), // Subtle border
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkAccent, // Light Grey buttons
          foregroundColor: Colors.black, // Black text on buttons
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
}