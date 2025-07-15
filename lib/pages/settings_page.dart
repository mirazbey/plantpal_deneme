// lib/pages/settings_page.dart (ÖĞRETİCİ TAMAMEN KALDIRILMIŞ HALİ)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantpal/pages/reminders_list_page.dart';
import 'package:plantpal/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Uygulama Ayarları', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Hatırlatıcılarım'),
            subtitle: const Text('Kurulu sulama hatırlatıcılarını görüntüle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersListPage()));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Konum Servisleri'),
            subtitle: const Text('Cihazın konum ayarlarını aç'),
            trailing: const Icon(Icons.launch),
            onTap: () async {
              await Geolocator.openLocationSettings();
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Hesap', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.photoURL ?? ''), radius: 20),
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
}