// lib/pages/plant_detail_page.dart (UYARI GİDERİLMİŞ HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/journal_entry.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/photo_viewer_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/widgets/info_card.dart';

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
      _journalEntriesFuture = DatabaseService.instance.getJournalEntries(widget.record.id);
    });
  }

  Future<void> _showAddJournalEntryDialog() async {
    final noteController = TextEditingController();
    File? selectedImage;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
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
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
                      
                      // --- DÜZELTME BURADA ---
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                      // -------------------------
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

    if (shouldSave == true) {
      _refreshJournal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record.nickname, style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewerPage(imageFile: widget.record.image),
                  ),
                );
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 2, blurRadius: 10)],
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
              child: Text(
                'Bakım Günlüğü',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<JournalEntry>>(
              future: _journalEntriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
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
                            Text(
                              DateFormat.yMMMMd('tr_TR').format(entry.date),
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