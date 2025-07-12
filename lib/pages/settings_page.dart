// lib/pages/settings_page.dart (TEMİZLENMİŞ VE DOĞRU HALİ)

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: const [
          // Gelecekte buraya yeni ayarlar eklenecek.
          // Şimdilik boş bir liste olarak duruyor.
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Tema Ayarları (Yakında)'),
          ),
          ListTile(
            leading: Icon(Icons.login_rounded),
            title: Text('Google ile Giriş (Yakında)'),
          ),
        ],
      ),
    );
  }
}