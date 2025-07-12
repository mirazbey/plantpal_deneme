// lib/pages/reminders_list_page.dart (YENİ SİSTEME UYUMLU HALİ)

import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/main.dart'; // showSimpleNotification fonksiyonunu import etmek için

class RemindersListPage extends StatelessWidget {
  const RemindersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Test Ekranı'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bu ekran, Android Alarm Yöneticisi\'nin doğru çalışıp çalışmadığını test eder.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.alarm_add_rounded),
                label: const Text('1 Dakika Sonrasına Test Alarmı Kur'),
                onPressed: () async {
                  // `await`'ten önce messenger'ı yakala
                  final messenger = ScaffoldMessenger.of(context);
                  
                  print("Alarm kuruluyor...");

                  await AndroidAlarmManager.oneShot(
                    const Duration(minutes: 1), // 1 dakika sonra
                    0, // Bu alarm için benzersiz bir ID
                    showSimpleNotification, // main.dart'ta tanımladığımız fonksiyonu çağır
                    exact: true,
                    wakeup: true,
                  );

                  print("Alarm kuruldu.");
                  
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Test alarmı 1 dakika sonrasına kuruldu!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}