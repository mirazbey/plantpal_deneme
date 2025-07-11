import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Android için başlangıç ayarları. @mipmap/ic_launcher, uygulamanın standart ikonudur.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Zaman dilimlerini kullanıma hazırlıyoruz.
    tz.initializeTimeZones();
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Haftalık tekrarlayan bildirim kuran fonksiyon
  Future<void> scheduleWeeklyNotification({
    required String plantName,
    required int day, // 1: Pazartesi, 7: Pazar
    required TimeOfDay time,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      0, // Her bildirim için benzersiz bir ID gerekir, prototip için 0 yeterli.
      'Sulama Zamanı!',
      '$plantName bitkini sulamayı unutma!',
      _nextInstanceOf(day, time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plantpal_channel',
          'Sulama Hatırlatıcıları',
          channelDescription: 'Bitki sulama bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Belirtilen gün ve saat için bir sonraki tarihi hesaplayan yardımcı fonksiyon
  tz.TZDateTime _nextInstanceOf(int day, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    // Eğer hesaplanan tarih geçmişte kaldıysa, bir sonraki haftaya atla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }
}

