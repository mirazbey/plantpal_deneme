import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için (pubspec.yaml'a ekleyeceğiz)
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/services/database_service.dart';

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
    await DatabaseService.instance.deleteReminder(id);
    // AndroidAlarmManager.cancel(id); // Alarmı da iptal et
    _refreshReminders(); // Listeyi yenile
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
              child: Text('Henüz kurulu bir hatırlatıcınız yok.'),
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
                leading: CircleAvatar(
                  backgroundImage: FileImage(File(reminder.imagePath)),
                ),
                title: Text(reminder.plantNickname),
                subtitle: Text(formattedDate),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
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