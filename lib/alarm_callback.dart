// lib/alarm_callback.dart (ZİNCİRLEME ALARM MANTIĞI)

import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/notification_service.dart';

@pragma('vm:entry-point')
void fireAlarm(int id) async {
  DartPluginRegistrant.ensureInitialized();
  
  // 1. Bildirimi göster
  final notificationService = NotificationService();
  await notificationService.initialize();
  notificationService.showNotification(
    id: id,
    title: 'Sulama Zamanı!',
    body: 'Bitkilerini sulamayı unutma! 🪴',
  );

  // 2. Veritabanından bu alarmın bilgilerini al
  final dbService = DatabaseService.instance;
  final reminders = await dbService.getAllReminders();
  final currentReminder = reminders.firstWhere((r) => r.id == id, orElse: () => Reminder(id: 0, plantId: '', plantNickname: '', imagePath: '', reminderDate: DateTime.now(), intervalDays: -1));

  // 3. Eğer bu periyodik bir alarm ise, bir sonrakini kur
  if (currentReminder.intervalDays > 0) {
    final nextAlarmTime = DateTime.now().add(Duration(days: currentReminder.intervalDays));
    
    await AndroidAlarmManager.oneShotAt(
      nextAlarmTime,
      id, // Aynı ID ile bir sonraki alarmı kuruyoruz
      fireAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
    );

    // Veritabanındaki tarihi de güncelle
    final updatedReminder = Reminder(
      id: currentReminder.id,
      plantId: currentReminder.plantId,
      plantNickname: currentReminder.plantNickname,
      imagePath: currentReminder.imagePath,
      reminderDate: nextAlarmTime,
      intervalDays: currentReminder.intervalDays,
    );
    await dbService.updateReminder(updatedReminder);
  } else {
    // Tek seferlik ise, veritabanından sil
    await dbService.deleteReminder(id);
  }
}