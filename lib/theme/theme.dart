import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    // Surface
    surface: Color(0xFFF0F0F0),
    onSurface: Colors.black,

    primary: Color(0xFFF0F8FF),
    onPrimary: Colors.black87,

    // primary: Colors.grey.shade300,
    secondary: Color(0xFFFBFCF8),
    onSecondary: Colors.white,

    tertiary: Color(0xFF5acbb1),
    onTertiary: Colors.white,

    onSurfaceVariant: const Color(0xFFFAF0DC),
    onPrimaryFixed: Colors.redAccent,

    onSecondaryContainer: Color(0xFF8ff8bf),

    onPrimaryContainer: Colors.blueGrey.shade50,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    // surface ==> background color
    surface: Color(0xFF1E1E1E), // A soft dark gray for the main background
    onSurface: Colors.white,
    primary: Color(0xFF2D2D2D), // Slightly lighter gray for elements
    onPrimary: Colors.white,
    secondary: Color(0xFF3B82F6), // A cool blue that matches your aesthetic
    // secondary: Color(0xFF3A7CA5), // A cool blue that matches your aesthetic
    onSecondary: Colors.white,
    tertiary: Color(0xFF2DD4BF), // A muted teal that complements the blue
    onTertiary: Colors.white,
    onSurfaceVariant: Colors.black,
    onPrimaryFixed: Colors.redAccent,
    onPrimaryContainer: Color(0xFF424242),

    // Another theme GPT
    // surface: Color(0xFF121212), // Dark, neutral background
    // onSurface: Colors.white, // Text on dark surface needs to be light for contrast
    // primary: Color(0xFF1E1E1E), // Slightly lighter gray for contrast with the surface
    // onPrimary: Colors.white70, // Softer white for readability on primary
    // // primary: Colors.grey.shade800,
    // secondary: Color(0xFFBB86FC), // Soft purple for a modern accent
    // onSecondary: Colors.black, // Text on secondary should contrast the purple
    // tertiary: Color(0xFF03DAC6), // Cyan for cool minimal accents
    // onTertiary: Colors.black, // Text on tertiary should contrast the cyan
    // onSurfaceVariant: Colors.black38, // Muted, subtle contrast for variants
  ),
);
