import 'package:plantpal/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:plantpal/main_screen_shell.dart'; // YENİ YOL
import 'package:plantpal/services/notification_service.dart'; // Bu satırda da hata olacak

void main() async {
  // Uygulama başlamadan önce bazı ayarların hazır olmasını sağlıyoruz.
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  runApp(const PlantPalApp());
}

class PlantPalApp extends StatelessWidget {
  const PlantPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantPal',
      theme: AppTheme.lightTheme,
      home: const MainScreenShell(), // Bu satırda da hata olacak
      debugShowCheckedModeBanner: false,
    );
  }
}