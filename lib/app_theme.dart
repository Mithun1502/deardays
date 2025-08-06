import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.indigo,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.indigo),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple),
    ),
  ),
);

const Gradient lightGradient = LinearGradient(
  colors: [Color.fromARGB(255, 3, 60, 86), Color(0xFFE1F5FE)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const Gradient darkGradient = LinearGradient(
  colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 79, 55, 75)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
