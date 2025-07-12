// lib/services/notification_service.dart (NİHAİ VE DOĞRU ZAMANLAMA MANTIĞI)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    tz.initializeTimeZones();
    // Cihazın yerel saat dilimini alıp ayarlamak, olası hataları önler
    try {
      final String timeZoneName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // ignore: avoid_print
      print("Zaman dilimi ayarlanamadı: $e");
    }

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestAndroidPermission() async {
    if (Platform.isAndroid) {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleTestNotification() async {
    await _notificationsPlugin.zonedSchedule(
      999, 'PlantPal Test', 'Eğer bu bildirim geldiyse, test başarılı!',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
      const NotificationDetails(
        android: AndroidNotificationDetails('plantpal_test_channel', 'Test Bildirimleri', importance: Importance.max, priority: Priority.high),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  Future<void> scheduleWeeklyNotification({
    required int id,
    required String plantName,
    required int day, // 1: Pazartesi, 7: Pazar
    required TimeOfDay time,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      'Sulama Zamanı!',
      '"$plantName" adlı bitkini sulamayı unutma!',
      _nextInstanceOf(day, time), // YENİ HESAPLAMA FONKSİYONU KULLANILACAK
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plantpal_channel', 'Sulama Hatırlatıcıları',
          channelDescription: 'Bitki sulama bildirimleri',
          importance: Importance.max, priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Haftalık tekrar için bu zorunlu
    );
  }

  // --- YENİ VE DAHA SAĞLAM ZAMANLAMA HESAPLAMA FONKSİYONU ---
  tz.TZDateTime _nextInstanceOf(int weekday, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // İstenen gün ve saat için bu haftanın tarihini oluştur
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    // Eğer hesaplanan gün ve saat, şu andan önceyse veya bugün değilse,
    // doğru güne ve gelecekteki bir zamana ulaşana kadar günleri ileri sar.
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}