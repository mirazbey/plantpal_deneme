// lib/alarm_callback.dart (GEREKSİZ IMPORT KALDIRILMIŞ NİHAİ KOD)

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/notification_service.dart';
import 'package:flutter/material.dart'; // Bu import, debugPrint için yeterlidir.
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
void fireAlarm(int id) async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugPrint("Alarm ($id) tetiklendi, arka plan işlemi başladı.");

  final notificationService = NotificationService();
  await notificationService.initialize();
  
  final dbService = DatabaseService.instance;
  final reminders = await dbService.getAllReminders();
  final currentReminder = reminders.firstWhere((r) => r.id == id, orElse: () => Reminder(id: 0, plantId: '', plantNickname: 'Bitkilerinin', imagePath: '', reminderDate: DateTime.now(), intervalDays: -1));

  notificationService.showNotification(
    id: id,
    title: 'Sulama Zamanı!',
    body: '${currentReminder.plantNickname} sulamayı unutma! 🪴',
  );

  if (currentReminder.intervalDays > 0) {
    final nextAlarmTime = DateTime.now().add(Duration(days: currentReminder.intervalDays));
    
    await AndroidAlarmManager.oneShotAt(
      nextAlarmTime,
      id,
      fireAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );

    final updatedReminder = Reminder(
      id: currentReminder.id,
      plantId: currentReminder.plantId,
      plantNickname: currentReminder.plantNickname,
      imagePath: currentReminder.imagePath,
      reminderDate: nextAlarmTime,
      intervalDays: currentReminder.intervalDays,
    );
    await dbService.updateReminder(updatedReminder);

    debugPrint("Periyodik alarm ($id) bir sonraki tetikleme için güncellendi: $nextAlarmTime");

  } else {
    await dbService.deleteReminder(id);
    debugPrint("Tek seferlik alarm ($id) tamamlandı ve veritabanından silindi.");
  }
}