// lib/theme/app_theme.dart (UYARILAR GİDERİLMİŞ HALİ)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 'final' yerine 'const' kullanıldı
  static const Color primaryGreen = Color(0xFF4A6553);
  static const Color accentColor = Color(0xFF8EAB9B);
  
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.montserrat(
        color: primaryText,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData( // <-- 'const' eklendi
        color: primaryText,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.montserrat(color: primaryText),
      bodyMedium: GoogleFonts.montserrat(color: secondaryText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );
}