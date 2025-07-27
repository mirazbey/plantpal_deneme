// lib/theme/app_theme.dart (RENKLER CONST YAPILDI)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // DÜZELTME: Renkleri const olarak tanımlıyoruz
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color scaffoldColor = Color(0xFFF9F9F9);
  static const Color textColor = Color(0xFF293241);
  static const Color accentColor = Color(0xFF3D5A80);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: scaffoldColor,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: accentColor),
    ),
    cardColor: Colors.white,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme)
        .apply(bodyColor: textColor, displayColor: textColor),
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
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    iconTheme: const IconThemeData(color: accentColor),
  );
}