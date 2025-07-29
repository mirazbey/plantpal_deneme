// lib/pages/calendar_page.dart (ARAYÜZ SORUNU ÇÖZÜLMÜŞ FİNAL KOD)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:plantpal/models/journal_entry.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iconsax/iconsax.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isLoading = true;
  Map<DateTime, List<JournalEntry>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final entries = await DatabaseService.instance.getAllJournalEntries();
      final groupedEvents = _groupEvents(entries);
      if (mounted) {
        setState(() {
          _events = groupedEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Takvim verileri yüklenirken hata: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<JournalEntry> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // DÜZELTME: FloatingActionButton kaldırıldı.
      body: SafeArea(
        child: Column(
          children: [
            // TAKVİM WIDGET'I
            TableCalendar(
              locale: 'tr_TR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // Sadece focus'u değiştirir, seçimi değiştirmez
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppTheme.accentColor.withAlpha(128), shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              ),
               headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.montserrat(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(),
            ),
            // OLAY LİSTESİ
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildEventList(selectedEvents),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<JournalEntry> events) {
    if (events.isEmpty) {
      return const Center(child: Text("Seçili gün için kayıt bulunamadı."));
    }
    return ListView.builder(
      // DÜZELTME: Artık FAB olmadığı için alttaki ekstra boşluğa gerek yok.
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: Icon(_getIconForEntryType(event.type), color: AppTheme.primaryGreen),
            title: Text(event.note),
            subtitle: Text('Saat: ${DateFormat.Hm('tr_TR').format(event.date)} - ${event.type}'),
          ),
        );
      },
    );
  }

  Map<DateTime, List<JournalEntry>> _groupEvents(List<JournalEntry> entries) {
    Map<DateTime, List<JournalEntry>> data = {};
    for (var entry in entries) {
      DateTime date = DateTime.utc(entry.date.year, entry.date.month, entry.date.day);
      if (data[date] == null) data[date] = [];
      data[date]!.add(entry);
    }
    return data;
  }

  IconData _getIconForEntryType(String type) {
    switch (type) {
      case 'Sulama': return Iconsax.drop;
      case 'Gübreleme': return Iconsax.cup;
      case 'İlaçlama': return Iconsax.shield_tick;
      case 'Temizlik': return Iconsax.brush_1;
      default: return Iconsax.health;
    }
  }
}