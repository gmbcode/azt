import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.grey.shade500,
    secondary: const Color.fromARGB(255, 39, 39, 39),
    tertiary: const Color.fromARGB(255, 25, 25, 25),
    inversePrimary: Colors.grey.shade300,
  ), // ColorScheme.dark
  scaffoldBackgroundColor: Colors.grey.shade900,
); // ThemeData