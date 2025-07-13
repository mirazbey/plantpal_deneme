// lib/services/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Başlangıçta sistem temasını kullan

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Kaydedilmiş temayı yükle
  }

  // Temayı değiştiren fonksiyon
  void setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners(); // Arayüzü güncellemek için dinleyicilere haber ver
    
    // Seçimi hafızaya kaydet
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', themeMode.index);
  }

  // Hafızadaki temayı yükleyen fonksiyon
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Kayıtlı bir tema yoksa, sistem varsayılanını kullan (index 0)
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }
}