// lib/providers/bottom_nav_provider.dart

import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 1; // Başlangıç sayfası Tanımla (index 1)

  int get currentIndex => _currentIndex;

  void changePage(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }
}