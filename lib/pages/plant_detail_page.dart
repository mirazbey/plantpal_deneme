// lib/pages/plant_detail_page.dart (TASARIMA UYGUN NİHAİ KOD)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- EKSİK IMPORT
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/journal_entry.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/widgets/info_card.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/alarm_callback.dart';
import 'package:plantpal/theme/app_theme.dart'; // <-- EKSİK IMPORT

class PlantDetailPage extends StatefulWidget {
  final PlantRecord record;
  const PlantDetailPage({super.key, required this.record});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> with SingleTickerProviderStateMixin {
  late Future<List<JournalEntry>> _journalEntriesFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Başlangıç sekmesi "Genel Bilgi"
    // Tab'ın değişimini dinlemek için listener ekliyoruz
    _tabController.addListener(() {
      setState(() {}); // FAB'ın görünürlüğünü güncellemek için
    });
    _refreshJournal();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  void _refreshJournal() {
    setState(() {
      _journalEntriesFuture =
          DatabaseService.instance.getJournalEntries(widget.record.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.record.nickname,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Hero(
                tag: 'plant_image_${widget.record.id}',
                child: Image.file(
                  widget.record.image,
                  fit: BoxFit.cover,
                  color: Colors.black.withAlpha(80),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
             actions: [
              IconButton(
                icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
                tooltip: 'Hatırlatıcı Kur',
                onPressed: () => _scheduleAlarm(widget.record),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildWateringInfoCard(),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryText,
                unselectedLabelColor: AppTheme.secondaryText,
                indicatorColor: AppTheme.primaryGreen,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(text: 'Bakım Rehberi'),
                  Tab(text: 'Genel Bilgi'),
                  Tab(text: 'Geçmiş'),
                ],
              ),
            ),
            pinned: true,
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCareGuideTab(),
                _buildGeneralInfoTab(),
                _buildJournalTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2 ? FloatingActionButton.extended(
        onPressed: _showAddJournalEntryDialog,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text("Kayıt Ekle"),
      ) : null,
    );
  }

  Widget _buildCareGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(icon: Icons.water_drop_rounded, title: "Sulama", content: widget.record.plantInfo['Sulama Sıklığı'] ?? 'Bilgi Yok'),
          InfoCard(icon: Icons.wb_sunny_rounded, title: "Işık İhtiyacı", content: widget.record.plantInfo['Işık İhtiyacı'] ?? 'Bilgi Yok'),
          if(widget.record.plantInfo['Tedavi Önerisi'] != null && widget.record.plantInfo['Tedavi Önerisi']!.isNotEmpty)
            InfoCard(icon: Icons.healing_rounded, title: "Tedavi Önerisi", content: widget.record.plantInfo['Tedavi Önerisi']!),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(icon: Icons.eco_rounded, title: 'Bitki Adı', content: widget.record.plantInfo['Bitki Adı'] ?? 'Bilgi Yok'),
          InfoCard(icon: Icons.favorite_border_rounded, title: 'Sağlık Durumu', content: widget.record.plantInfo['Sağlık Durumu'] ?? 'Bilgi Yok'),
          InfoCard(icon: Icons.info_outline_rounded, title: 'Günün Tavsiyesi', content: widget.record.plantInfo['Günün Tavsiyesi'] ?? 'Bilgi Yok'),
        ]
      ),
    );
  }

  Widget _buildJournalTab() {
    return FutureBuilder<List<JournalEntry>>(
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
          padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildWateringInfoCard() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
             Icon(Icons.water_drop_outlined, color: AppTheme.accentColor),
             SizedBox(width: 12),
             Expanded(child: Text('Sonraki sulama:', style: TextStyle(fontSize: 16))),
             Text('3 gün sonra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
             SizedBox(width: 12),
             Icon(Icons.water, color: Colors.blue),
          ],
        ),
      ),
    );
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
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}