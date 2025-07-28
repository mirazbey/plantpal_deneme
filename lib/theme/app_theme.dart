// lib/theme/app_theme.dart (UYARILAR GİDERİLMİŞ HALİ)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 'final' yerine 'const' kullanıldı
  static const Color primaryGreen = Color(0xFF4A6553);
  static const Color accentColor = Color(0xFF8EAB9B);
  
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);

  // --- ŞİMDİ BU YENİ RENKLERİ ALTINA EKLEYİN ---
  // Tasarımlarımızda konuştuğumuz renk paleti
  static const Color designPrimaryText = Color(0xFF2C3E50);
  static const Color designSecondaryText = Color(0xFF7F8C8D);
  static const Color designBackground = Color(0xFFF7F9F9);
  static const Color designAccentBlue = Color(0xFF3498DB);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: designBackground, // <-- BU SATIRI DEĞİŞTİRİN
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: GoogleFonts.montserrat(
        color: designPrimaryText, // <-- BU SATIRI DEĞİŞTİRİN
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData( // <-- 'const' eklendi
        color: designPrimaryText, // <-- BU SATIRI DEĞİŞTİRİN
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.montserrat(color: designPrimaryText),   // <-- BU SATIRI DEĞİŞTİRİN
      bodyMedium: GoogleFonts.montserrat(color: designSecondaryText), // <-- BU SATIRI DEĞİŞTİRİN
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
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: designAccentBlue, 
    ),
  );
}