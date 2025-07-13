// lib/theme/app_theme.dart (TYPO DÜZELTİLMİŞ HALİ)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ana Renkler
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkScaffoldColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // --- AÇIK TEMA ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    cardColor: Colors.white,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen, // <-- DÜZELTME BURADA
      foregroundColor: Colors.white,
    ),
  );

  // --- KARANLIK TEMA ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkScaffoldColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkScaffoldColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardColor: darkCardColor,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen, // <-- VE BURADA
      foregroundColor: Colors.white,
    ),
  );
}