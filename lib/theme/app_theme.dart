import 'package:flutter/material.dart';

class AppTheme {
  // Logonuzdaki ana yeşil rengi tanımlıyoruz
  static const Color primaryGreen = Color(0xFF4CAF50); // Bu renk kodunu istediğinizle değiştirebilirsiniz

  // Uygulamanın genel teması
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Açık gri arka plan

    // AppBar (Üst bar) teması
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),

    // Buton teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white, // Buton üzerindeki yazı rengi
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Yüzen Aksiyon Butonu (Floating Action Button) teması
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),

    // Yazı stilleri
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  );
}