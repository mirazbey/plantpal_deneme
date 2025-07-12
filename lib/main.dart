// lib/main.dart (NİHAİ VE PİL DOSTU HALİ)

import 'dart:async';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:plantpal/main_screen_shell.dart';
import 'package:plantpal/services/notification_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.request();
  // Arka plan servislerini başlatıyoruz
  await initializeService();
  await AndroidAlarmManager.initialize(); // Alarm Manager'ı başlat
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'plantpal_service_channel',
    'PlantPal Servisi',
    description: 'Uygulamanın düzgün çalışması için gereklidir.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      // OTOMATİK BAŞLAMAYI KAPATIYORUZ. Sadece alarm tetiklediğinde başlayacak.
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'plantpal_service_channel',
      initialNotificationTitle: 'PlantPal Çalışıyor',
      initialNotificationContent: 'Hatırlatıcınız hazırlanıyor...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Gerçek sulama bildirimini göster
  notificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: 'Sulama Zamanı!',
    body: 'Bitkilerini sulamayı unutma! 🪴',
  );

  // Görev bitti, servisi 10 saniye sonra durdur.
  // Bu, bildirimin gönderilmesi için yeterli zaman tanır ve pil tasarrufu sağlar.
  Timer(const Duration(seconds: 10), () {
    service.stopSelf();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantPal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreenShell(),
    );
  }
}