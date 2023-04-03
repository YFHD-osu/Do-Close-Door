import 'package:flutter/material.dart';

class AppThemeData {
  static ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColorDark: Colors.grey[800],
    primaryColorLight: Colors.grey[300],
    primarySwatch: Colors.blue,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      iconColor: Colors.grey,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Colors.white),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(0))
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(0),
      )
    ),

  );

  static ThemeData lightMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColorDark: Colors.grey[100],
    primaryColorLight: Colors.white,
    primarySwatch: Colors.blue,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      fillColor: Colors.grey[200],
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black),
      border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(0))
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(0),
      )
    )
  );
}