import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color secondaryYellow = Color(0xFFFFCA28);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFF0F0F0);

  static ThemeData get themeData => ThemeData(
        scaffoldBackgroundColor: lightBackground,
        primaryColor: primaryOrange,
        colorScheme: const ColorScheme.light().copyWith(
          primary: primaryOrange,
          secondary: secondaryYellow,
          surface: surfaceColor,
          background: lightBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: primaryOrange),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceColor,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.grey,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          bodyLarge: TextStyle(color: Colors.black87),
        ),
        useMaterial3: true, // دعم Material 3
      );
}