// lib/pages/plant_detail_page.dart (CONTEXT HATASI GİDERİLMİŞ SON HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/journal_entry.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/photo_viewer_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/widgets/info_card.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/alarm_callback.dart';

class PlantDetailPage extends StatefulWidget {
  final PlantRecord record;
  const PlantDetailPage({super.key, required this.record});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  late Future<List<JournalEntry>> _journalEntriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshJournal();
  }

  void _refreshJournal() {
    setState(() {
      _journalEntriesFuture =
          DatabaseService.instance.getJournalEntries(widget.record.id);
    });
  }

  Future<void> _showAddJournalEntryDialog() async {
    final noteController = TextEditingController();
    File? selectedImage;

    // Await'ten önce context'i bir değişkene atamak en güvenli yoldur.
    final currentContext = context;

    final bool? shouldSave = await showDialog<bool>(
      context: currentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Günlük Kaydı'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Notunuz',
                        hintText: 'Bugün yeni bir yaprak çıkardı!',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    selectedImage == null
                        ? OutlinedButton.icon(
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text("Fotoğraf Ekle"),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setDialogState(() {
                                  selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                          )
                        : GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedImage = null;
                              });
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(selectedImage!, height: 100),
                            ),
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (noteController.text.isNotEmpty) {
                      final newEntry = JournalEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        plantId: widget.record.id,
                        date: DateTime.now(),
                        note: noteController.text,
                        image: selectedImage,
                      );
                      await DatabaseService.instance.addJournalEntry(newEntry);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    // Düzeltme: `mounted` kontrolü
    if (shouldSave == true && mounted) {
      _refreshJournal();
    }
  }

  // plant_detail_page.dart içindeki _scheduleAlarm fonksiyonunun YENİ HALİ

    Future<void> _scheduleAlarm(PlantRecord record) async {
      if (!mounted) return;

      final Map<String, int> reminderOptions = {
        'Tek seferlik (Bugün)': 0, 'Her gün': 1, 'Her 3 günde bir': 3,
        'Her 5 günde bir': 5, 'Haftada bir': 7,
      };

      final int? selectedInterval = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return SimpleDialog(
            title: Text('${record.nickname} için sulama sıklığı'),
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

      if (selectedInterval == null || !mounted) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime == null || !mounted) return;

      final intervalDays = selectedInterval;
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // ARTIK HER ZAMAN oneShotAt KULLANIYORUZ
      await AndroidAlarmManager.oneShotAt(
        scheduledDate,
        alarmId,
        fireAlarm, // Bu fonksiyon artık daha akıllı olacak
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true, // Cihaz yeniden başlayınca da çalışsın
      );

      final newReminder = Reminder(
        id: alarmId,
        plantId: record.id,
        plantNickname: record.nickname,
        imagePath: record.image.path,
        reminderDate: scheduledDate,
        intervalDays: intervalDays,
      );
      await DatabaseService.instance.insertReminder(newReminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${record.nickname} için hatırlatıcı kuruldu!')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record.nickname, style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_add_rounded),
            tooltip: 'Hatırlatıcı Kur',
            onPressed: () => _scheduleAlarm(widget.record),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PhotoViewerPage(imageFile: widget.record.image),
                  ),
                );
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 2, blurRadius: 10)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(widget.record.image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (var entry in widget.record.plantInfo.entries)
              InfoCard(
                icon: entry.key == 'Bitki Adı' ? Icons.eco_rounded :
                      entry.key == 'Sağlık Durumu' ? Icons.favorite_rounded :
                      entry.key == 'Sulama Sıklığı' ? Icons.water_drop_rounded :
                      entry.key == 'Günün Tavsiyesi' ? Icons.wb_cloudy_rounded :
                      entry.key == 'Işık İhtiyacı' ? Icons.wb_sunny_rounded :
                      Icons.info_rounded,
                title: entry.key,
                content: entry.value,
              ),
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Text('Bakım Günlüğü', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<List<JournalEntry>>(
              future: _journalEntriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Henüz bir günlük kaydı eklenmemiş.'),
                    ),
                  );
                }
                final entries = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMMd('tr_TR').format(entry.date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (entry.image != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(entry.image!),
                                ),
                              ),
                            Text(entry.note),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJournalEntryDialog,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text("Kayıt Ekle"),
      ),
    );
  }
}