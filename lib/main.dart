// lib/main.dart (DOĞRU İZİN İSTEME MANTIĞI)

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // YENİ İMPORT
import 'package:plantpal/main_screen_shell.dart';
import 'package:plantpal/services/notification_service.dart';
import 'package:plantpal/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim servisini başlat
  await NotificationService().initialize();
  
  // YENİ VE DOĞRU İZİN İSTEME KODU
  // Sadece Android platformunda çalışacak
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final bool? granted = await androidImplementation?.requestNotificationsPermission();

    // Konsola geri bildirim yazdır
    if (kDebugMode) {
      print("Bildirim izni istendi. Kullanıcı onayı: $granted");
    }
  }

  runApp(const MyApp());
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