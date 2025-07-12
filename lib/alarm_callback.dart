// lib/alarm_callback.dart
import 'package:plantpal/services/notification_service.dart';

@pragma('vm:entry-point')
void fireAlarm() {
  NotificationService().initialize().then((_) {
    NotificationService().showNotification(
      id: 0,
      title: 'Sulama Zamanı!',
      body: 'Bitkilerini sulamayı unutma!',
    );
  });
}