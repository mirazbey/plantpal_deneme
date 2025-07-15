// lib/pages/reminders_list_page.dart (GELİŞMİŞ VE DÜZENLENEBİLİR HALİ)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/alarm_callback.dart';

class RemindersListPage extends StatefulWidget {
  const RemindersListPage({super.key});

  @override
  State<RemindersListPage> createState() => _RemindersListPageState();
}

class _RemindersListPageState extends State<RemindersListPage> {
  late Future<List<Reminder>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _refreshReminders();
  }

  void _refreshReminders() {
    setState(() {
      _remindersFuture = DatabaseService.instance.getAllReminders();
    });
  }

  // Tekrarlama gününü okunabilir metne çeviren yardımcı fonksiyon
  String _getIntervalText(int intervalDays) {
    if (intervalDays == 0) return 'Tek seferlik';
    if (intervalDays == 1) return 'Her gün';
    return 'Her $intervalDays günde bir';
  }

  // Hatırlatıcıyı silme fonksiyonu
  Future<void> _deleteReminder(int id) async {
    await AndroidAlarmManager.cancel(id); // Önce alarmı iptal et
    await DatabaseService.instance.deleteReminder(id); // Sonra veritabanından sil
    _refreshReminders();
  }

  // Hatırlatıcıyı düzenleme fonksiyonu (YENİ)
  Future<void> _editReminder(Reminder reminder) async {
    if (!mounted) return;

    final Map<String, int> reminderOptions = {
      'Tek seferlik': 0, 'Her gün': 1, 'Her 3 günde bir': 3,
      'Her 5 günde bir': 5, 'Haftada bir': 7,
    };

    final int? newInterval = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text('${reminder.plantNickname} için yeni sıklık'),
          children: reminderOptions.entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, entry.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(entry.key),
              ),
            );
          }).toList(),
        );
      },
    );

    if (newInterval == null || !mounted) return;

    // Önce eski alarmı iptal et
    await AndroidAlarmManager.cancel(reminder.id);

    // Yeni alarmı kur
    if (newInterval > 0) {
      await AndroidAlarmManager.periodic(
        Duration(days: newInterval), reminder.id, fireAlarm,
        startAt: reminder.reminderDate, exact: true, wakeup: true, rescheduleOnReboot: true,
      );
    } else {
      await AndroidAlarmManager.oneShotAt(
        reminder.reminderDate, reminder.id, fireAlarm,
        exact: true, wakeup: true, allowWhileIdle: true,
      );
    }

    // Veritabanındaki kaydı güncelle
    final updatedReminder = Reminder(
      id: reminder.id,
      plantId: reminder.plantId,
      plantNickname: reminder.plantNickname,
      imagePath: reminder.imagePath,
      reminderDate: reminder.reminderDate,
      intervalDays: newInterval,
    );
    await DatabaseService.instance.updateReminder(updatedReminder);

    // Listeyi yenile
    _refreshReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatıcılarım'),
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Henüz kurulu bir hatırlatıcı yok.'),
            );
          }
          final reminders = snapshot.data!;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(reminder.plantNickname),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tarih: ${DateFormat.yMMMMd('tr_TR').add_Hm().format(reminder.reminderDate)}'),
                      // YENİ: Tekrarlama bilgisi
                      Text(
                        'Sıklık: ${_getIntervalText(reminder.intervalDays)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // YENİ: Düzenleme butonu
                      IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        tooltip: 'Sıklığı Düzenle',
                        onPressed: () => _editReminder(reminder),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Sil',
                        onPressed: () => _deleteReminder(reminder.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}