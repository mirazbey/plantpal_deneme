// lib/pages/settings_page.dart (YENİ VE DÜZENLİ HALİ)

import 'package:flutter/material.dart';
// Hatırlatıcılar listesi sayfasına yönlendirme yapacağız (bu dosyayı sonra oluşturacağız)
import 'package:plantpal/pages/reminders_list_page.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: ListView(
        children: [
          // --- UYGULAMA AYARLARI BÖLÜMÜ ---
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
              // Kullanıcıyı hatırlatıcı listesi sayfasına yönlendiriyoruz
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
            subtitle: const Text('Uygulama temasını değiştir (Yakında)'),
            onTap: () {},
          ),
          
          const SizedBox(height: 20),

          // --- HESAP AYARLARI BÖLÜMÜ ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Hesap',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login_rounded),
            title: const Text('Google ile Giriş Yap'),
            subtitle: const Text('Bitkilerini bulutta yedekle (Yakında)'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}