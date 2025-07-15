// lib/main.dart (SADELEŞTİRİLMİŞ HALİ)

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
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plantpal/services/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Permission.notification.request();
  await initializeService();
  await AndroidAlarmManager.initialize();
  await initializeDateFormatting('tr_TR', null);

  // Sadece AuthService için Provider kullanıyoruz
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

// ... initializeService ve onStart fonksiyonları aynı kalıyor ...

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantPal',
      debugShowCheckedModeBanner: false,
      // Sadece tek temamızı bağlıyoruz
      theme: AppTheme.lightTheme,
      home: const MainScreenShell(),
    );
  }
}

// ... (onStart ve initializeService fonksiyonları burada olmalı)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initialize();

  notificationService.showNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: 'Sulama Zamanı!',
    body: 'Bitkilerini sulamayı unutma! 🪴',
  );

  Timer(const Duration(seconds: 10), () {
    service.stopSelf();
  });
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'plantpal_service_channel', 'PlantPal Servisi',
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
      onStart: onStart, autoStart: false, isForegroundMode: true,
      notificationChannelId: 'plantpal_service_channel',
      initialNotificationTitle: 'PlantPal Çalışıyor',
      initialNotificationContent: 'Hatırlatıcınız hazırlanıyor...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: false, onForeground: onStart),
  );
}