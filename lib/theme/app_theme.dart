// lib/theme/app_theme.dart (YENİ VE TEK TEMA)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // YENİ RENK PALETİ
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color scaffoldColor = Color(0xFFF9F9F9); // Kırık Beyaz
  static const Color textColor = Color(0xFF293241);      // Koyu Antrasit
  static const Color accentColor = Color(0xFF3D5A80);     // Mavi-Gri Vurgu

  // --- TEK VE MÜKEMMEL TEMA ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: scaffoldColor,
    
    // AppBar Teması
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: accentColor), // İkonlar vurgu renginde
    ),

    // Kart Teması
    cardColor: Colors.white,

    // Yazı Tipi Teması
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme)
        .apply(bodyColor: textColor, displayColor: textColor),

    // Buton Teması
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

    // Yüzen Aksiyon Butonu Teması
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),

    // İkon Teması
    iconTheme: const IconThemeData(color: accentColor),
  );
}