// lib/alarm_callback.dart

import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
void fireAlarm() {
  // Bu fonksiyon tetiklendiğinde, sadece arka plan servisini başlatıyoruz.
  final service = FlutterBackgroundService();
  service.startService();
}