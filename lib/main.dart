// lib/main.dart (NİHAİ VE EN BASİT HALİ)

import 'package:flutter/material.dart';
import 'package:plantpal/main_screen_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:plantpal/services/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AndroidAlarmManager.initialize();
  await initializeDateFormatting('tr_TR', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PlantPal',
      debugShowCheckedModeBanner: false,
      home: MainScreenShell(), // <-- Uygulama her zaman buradan başlar.
    );
  }
}