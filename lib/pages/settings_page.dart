// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:plantpal/pages/reminders_list_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bug_report_rounded),
            title: const Text('Bildirim Teşhis Ekranı'),
            subtitle: const Text('Kurulu hatırlatıcıları gör ve test et.'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersListPage())),
          ),
        ],
      ),
    );
  }
}