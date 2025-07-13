import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

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

  Future<void> _deleteReminder(int id) async {
    // Önce veritabanından sil
    await DatabaseService.instance.deleteReminder(id);
    // Sonra kurulu alarmı iptal et
    await AndroidAlarmManager.cancel(id);

    // Listeyi yenile
    _refreshReminders(); 

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hatırlatıcı başarıyla silindi.')),
      );
    }
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
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Henüz kurulu bir hatırlatıcınız yok.\nBir bitkiyi kaydettikten sonra çıkan "Hatırlatıcı Kur" butonu ile ekleyebilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }

          final reminders = snapshot.data!;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              // Tarihi daha okunaklı bir formata çeviriyoruz
              final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(reminder.reminderDate);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: FileImage(File(reminder.imagePath)),
                ),
                title: Text(reminder.plantNickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hatırlatıcıyı Sil',
                  onPressed: () => _deleteReminder(reminder.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}