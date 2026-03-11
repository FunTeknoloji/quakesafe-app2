import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFFBB86FC);
  static const Color pureBlack = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF121212);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: pureBlack,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: primaryPurple,
      surface: surfaceColor,
      background: pureBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: pureBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 4,
      shadowColor: primaryPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: pureBlack,
      selectedItemColor: primaryPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}
