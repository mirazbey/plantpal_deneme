// lib/pages/settings_page.dart (TEMA SEÇİMİ EKLENMİŞ SON HALİ)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plantpal/pages/reminders_list_page.dart';
import 'package:plantpal/services/auth_service.dart';
import 'package:plantpal/services/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final User? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Uygulama Ayarları',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Hatırlatıcılarım'),
            subtitle: const Text('Kurulu sulama hatırlatıcılarını görüntüle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersListPage()),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Görünüm'),
            subtitle: Text(_getThemeString(themeProvider.themeMode)),
            onTap: () {
              // --- TEMA SEÇİM DİYALOĞUNU GÖSTER ---
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tema Seçin'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('Sistem Varsayılanı'),
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) themeProvider.setTheme(value);
                          Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Açık Tema'),
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          if (value != null) themeProvider.setTheme(value);
                           Navigator.of(context).pop();
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Karanlık Tema'),
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                           if (value != null) themeProvider.setTheme(value);
                           Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // --- HESAP BÖLÜMÜ ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Hesap',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          if (user == null)
            ListTile(
              leading: const Icon(Icons.login_rounded),
              title: const Text('Google ile Giriş Yap'),
              subtitle: const Text('Bitkilerini bulutta yedekle'),
              onTap: () {
                authService.signInWithGoogle();
              },
            )
          else
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL ?? ''),
                    radius: 20,
                  ),
                  title: Text(user.displayName ?? 'Kullanıcı'),
                  subtitle: Text(user.email ?? 'E-posta bilgisi yok'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    authService.signOut();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Tema modunu okunabilir bir metne çeviren yardımcı fonksiyon
  String _getThemeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Karanlık Tema';
      case ThemeMode.system:
        return 'Sistem Varsayılanı';
    }
  }
}