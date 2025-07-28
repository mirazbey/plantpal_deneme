import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/journal_entry.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/widgets/info_card.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/alarm_callback.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:plantpal/pages/light_meter_page.dart';


class PlantDetailPage extends StatefulWidget {
  final PlantRecord record;
  const PlantDetailPage({super.key, required this.record});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  late Future<List<JournalEntry>> _journalEntriesFuture;
  bool _isListView = true;

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

  IconData _getIconForEntryType(String type) {
    switch (type) {
      case 'Sulama': return Icons.water_drop;
      case 'Gübreleme': return Icons.eco;
      case 'İlaçlama': return Icons.bug_report;
      case 'Temizlik': return Icons.cleaning_services;
      default: return Icons.spa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddJournalEntryDialog,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text("Kayıt Ekle"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290.0,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.record.nickname,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Hero(
                tag: 'plant_image_${widget.record.id}',
                child: Image.file(
                  widget.record.image,
                  fit: BoxFit.cover,
                  color: Colors.black.withAlpha(85),
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
          const SliverToBoxAdapter(
            child: QuickInfoPanel(),
          ),
          SliverToBoxAdapter(child: _buildSectionTitle('Bakım Rehberi')),
          _buildCareGuideSlivers(),
          SliverToBoxAdapter(child: _buildSectionTitle('Genel Bilgi')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16,0,16,16),
              child: _buildGeneralInfoContent(),
            ),
          ),
          SliverToBoxAdapter(child: _buildSectionTitle('Geçmiş')),
          SliverToBoxAdapter(
            child: _buildJournalContent(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryText,
        ),
      ),
    );
  }

  Widget _buildCareGuideSlivers() {
    final wateringInfo = widget.record.plantInfo['Sulama Sıklığı'] ?? 'Sulama bilgisi mevcut değil.';
    final lightInfo = widget.record.plantInfo['Işık İhtiyacı'] ?? 'Işık bilgisi mevcut değil.';
    final fertilizingInfo = widget.record.plantInfo['Gübreleme'] ?? '';
    final temperatureInfo = widget.record.plantInfo['Sıcaklık ve Nem'] ?? '';
    final treatmentInfo = widget.record.plantInfo['Tedavi Önerisi'] ?? '';

    return SliverList(
      delegate: SliverChildListDelegate([
        if (wateringInfo.isNotEmpty) _buildExpansionCard(title: 'Sulama', content: wateringInfo, icon: Icons.water_drop_outlined),
        if (lightInfo.isNotEmpty) _buildExpansionCard(title: 'Işık İhtiyacı', content: lightInfo, icon: Icons.wb_sunny_outlined),
        if (fertilizingInfo.isNotEmpty) _buildExpansionCard(title: 'Gübreleme', content: fertilizingInfo, icon: Icons.eco_outlined),
        if (temperatureInfo.isNotEmpty) _buildExpansionCard(title: 'Sıcaklık ve Nem', content: temperatureInfo, icon: Icons.thermostat_outlined),
        if (treatmentInfo.isNotEmpty) _buildExpansionCard(title: 'Tedavi Önerisi', content: treatmentInfo, icon: Icons.healing_outlined),
      ]),
    );
  }
  
  Widget _buildExpansionCard({required String title, required String content, required IconData icon}) {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          leading: Icon(icon, color: AppTheme.accentColor),
          title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content, style: GoogleFonts.montserrat(height: 1.5)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoContent() {
    return Column(
      children: [
        InfoCard(icon: Icons.eco_rounded, title: 'Bitki Adı', content: widget.record.plantInfo['Bitki Adı'] ?? 'Bilgi Yok'),
        InfoCard(icon: Icons.favorite_border_rounded, title: 'Sağlık Durumu', content: widget.record.plantInfo['Sağlık Durumu'] ?? 'Bilgi Yok'),
        InfoCard(icon: Icons.info_outline_rounded, title: 'Günün Tavsiyesi', content: widget.record.plantInfo['Günün Tavsiyesi'] ?? 'Bilgi Yok'),
      ],
    );
  }

  Widget _buildJournalContent() {
    return FutureBuilder<List<JournalEntry>>(
      future: _journalEntriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Henüz bir günlük kaydı eklenmemiş.'),
          ));
        }
        final entries = snapshot.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleButtons(
                isSelected: [_isListView, !_isListView],
                onPressed: (index) => setState(() => _isListView = index == 0),
                borderRadius: BorderRadius.circular(8.0),
                selectedColor: Colors.white,
                fillColor: AppTheme.primaryGreen,
                color: AppTheme.primaryGreen,
                constraints: BoxConstraints(minHeight: 40.0, minWidth: (MediaQuery.of(context).size.width - 40) / 2),
                children: const [Text('Liste'), Text('Takvim')],
              ),
            ),
            _isListView
                ? _buildJournalListView(entries)
                : _buildJournalCalendarView(entries),
          ],
        );
      },
    );
  }

  Widget _buildJournalListView(List<JournalEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              _getIconForEntryType(entry.type),
              color: AppTheme.primaryGreen,
            ),
            title: Text(
              entry.note,
              style: GoogleFonts.montserrat(),
            ),
            subtitle: Text(
              DateFormat.yMMMMd('tr_TR').format(entry.date),
              style: GoogleFonts.montserrat(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJournalCalendarView(List<JournalEntry> entries) {
    final Map<DateTime, List<Widget>> events = {};
    for (var entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (events[date] == null) events[date] = [];
      events[date]!.add(
        Icon(_getIconForEntryType(entry.type), color: AppTheme.accentColor, size: 16)
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        locale: 'tr_TR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        eventLoader: (day) {
          return events[DateTime(day.year, day.month, day.day)] ?? [];
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((e) => e as Widget).toList(),
                ), 
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _showAddJournalEntryDialog() async {
    final noteController = TextEditingController();
    File? selectedImage;
    String selectedType = 'Bakım';
    final List<String> entryTypes = ['Sulama', 'Gübreleme', 'İlaçlama', 'Temizlik', 'Bakım'];

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
                    Wrap(
                      spacing: 8.0,
                      children: entryTypes.map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: selectedType == type,
                          onSelected: (isSelected) {
                            if (isSelected) {
                              setDialogState(() => selectedType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Notunuz', hintText: 'Bugün yeni bir yaprak çıkardı!'),
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
                        type: selectedType,
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

    if (shouldSave == true && mounted) {
      _refreshJournal();
    }
  }

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
    final TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null || !mounted) return;
    final intervalDays = selectedInterval;
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      alarmId,
      fireAlarm,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      rescheduleOnReboot: true,
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

class QuickInfoPanel extends StatelessWidget {
  const QuickInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _InfoItem(
            icon: Icons.thermostat_outlined,
            value: 'Yeni Başlayan',
            label: 'Zorluk',
            color: AppTheme.primaryText,
          ),
          const _InfoItem(
            icon: Icons.wb_sunny_outlined,
            value: 'Dolaylı Işık',
            label: 'Işık',
            color: AppTheme.primaryText,
          ),
          const _InfoItem(
            icon: Icons.water_drop_outlined,
            value: 'Nemli Toprak',
            label: 'Sulama',
            color: AppTheme.primaryText,
          ),
          InkWell(
            onTap: () {
              // --- DEĞİŞİKLİK BURADA ---
              // Artık Işık Ölçer sayfasını açıyoruz
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LightMeterPage()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Test Et',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 90,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
