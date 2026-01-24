import 'package:flutter/material.dart';

class AppTheme {
  // 🔒 Brand colors (DO NOT CHANGE)
  static const Color primaryPurple = Color(0xFF7b2cbf);
  static const Color deepPurple = Color(0xFF5a189a);
  static const Color darkPurple = Color(0xFF3c096c);

  // ─────────────────────────────────────────
  // 🌞 LIGHT THEME
  // ─────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    primaryColor: primaryPurple,

    scaffoldBackgroundColor: const Color(0xFFfaf7ff),

    colorScheme: ColorScheme.light(
      primary: primaryPurple,
      secondary: deepPurple,
      background: const Color(0xFFfaf7ff),
      surface: Colors.white,
      onPrimary: Colors.white,
      onBackground: const Color(0xFF1f1f1f),
      onSurface: const Color(0xFF1f1f1f),
    ),

    // Text styling
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkPurple,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: deepPurple,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF333333),
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF444444),
      ),
    ),

    iconTheme: const IconThemeData(
      color: deepPurple,
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: primaryPurple,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFfaf7ff),
      selectedItemColor: primaryPurple,
      unselectedItemColor: Color(0xFF9a8fbf),
      showUnselectedLabels: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFe5d8ff),
      thickness: 1,
    ),
  );

  // ─────────────────────────────────────────
  // 🌙 DARK THEME
  // ─────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    primaryColor: primaryPurple,

    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: ColorScheme.dark(
      primary: primaryPurple,
      secondary: deepPurple,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1e1e1e),
      onPrimary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    // Text styling (same hierarchy, higher contrast)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFe6e6e6),
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFcfcfcf),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: primaryPurple,
      contentTextStyle: TextStyle(color: Colors.white),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1a1a1a),
      selectedItemColor: primaryPurple,
      unselectedItemColor: Color(0xFF9a8fbf),
      showUnselectedLabels: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF2a2a2a),
      thickness: 1,
    ),
  );
}
