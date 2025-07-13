// lib/main_screen_shell.dart (TÜM UYARILARI GİDERİLMİŞ SON HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
import 'package:plantpal/pages/settings_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart';
import 'package:plantpal/services/weather_service.dart';
import 'package:plantpal/theme/app_theme.dart';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/alarm_callback.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/pages/plant_saved_page.dart'; // <-- HATA GİDEREN SATIR


class MainScreenShell extends StatefulWidget {
  const MainScreenShell({super.key});
  @override
  State<MainScreenShell> createState() => _MainScreenShellState();
}

class _MainScreenShellState extends State<MainScreenShell> {
  bool _showSplash = true;
  int _pageIndex = 1;
  File? _selectedImage;
  String _plantInfo = "Tanımam için bana bir bitki göster!";
  bool _isLoading = false;
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;
  List<PlantRecord> _plantHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _refreshPlants();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showSplash = false);
  }

  Future<void> _refreshPlants() async {
    final localPlants = await DatabaseService.instance.getAllPlants();
    if (mounted) {
      setState(() {
        _plantHistory = localPlants;
      });
    }

    final cloudPlants = await DatabaseService.instance.getPlantsFromCloud();
    if (mounted && cloudPlants.isNotEmpty) {
       final allPlants = await DatabaseService.instance.getAllPlants();
       setState(() {
         _plantHistory = allPlants;
       });
    }
  }

  List<PlantPrediction> _parsePredictions(String rawText) {
    final List<PlantPrediction> predictions = [];
    final parts = rawText.split(RegExp(r'---TAHMİN \d+---'));
    for (var part in parts) {
      if (part.trim().isEmpty) continue;
      String percentage = '', name = '', health = '', watering = '', advice = '', light = '', treatment = '';
      final lines = part.split('\n');
      for (var line in lines) {
        final keyValuePair = line.split(':');
        if (keyValuePair.length < 2) continue;
        final key = keyValuePair[0].replaceAll('**', '').trim();
        final value = keyValuePair.sublist(1).join(':').trim().replaceAll('**', '');
        switch (key) {
          case 'Tahmin Yüzdesi': percentage = value; break;
          case 'Bitki Adı': name = value; break;
          case 'Sağlık Durumu': health = value; break;
          case 'Tedavi Önerisi': treatment = value; break;
          case 'Sulama Sıklığı': watering = value; break;
          case 'Günün Tavsiyesi': advice = value; break;
          case 'Işık İhtiyacı': light = value; break;
        }
      }
      if (name.isNotEmpty) {
        predictions.add(PlantPrediction(percentage: percentage, name: name, health: health, watering: watering, advice: advice, light: light, treatment: treatment));
      }
    }
    return predictions;
  }

  Future<void> _pickImageAndIdentify(ImageSource source) async {
    setState(() => _pageIndex = 1);
    _processImageIdentification(source);
  }

  Future<void> _processImageIdentification(ImageSource source) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _selectedImage = File(pickedFile.path);
      _plantInfo = "Konum alınıyor...";
      _predictions = [];
    });
    final locationService = LocationService();
    final Position? position = await locationService.getCurrentLocation();
    String? weatherString = "Hava durumu bilgisi alınamadı.";
    if (position != null && mounted) {
      setState(() => _plantInfo = "Hava durumu alınıyor...");
      final weatherService = WeatherService();
      final weatherData = await weatherService.getCurrentWeather(position);
      if (weatherData != null) {
        final description = weatherData['weather'][0]['description'];
        final temp = weatherData['main']['temp'];
        weatherString = "$description, $temp °C";
      }
    }
    if (!mounted) return;
    setState(() => _plantInfo = "Bitki tanınıyor, lütfen bekleyin...");
    final result = await GeminiService.getPlantInfo(_selectedImage!, weatherString);
    if (!mounted) return;
    if (result != null && result.contains('---TAHMİN')) {
      final predictions = _parsePredictions(result);
      setState(() {
        _plantInfo = result;
        _predictions = predictions;
        _selectedPredictionIndex = 0;
        _isLoading = false;
      });
    } else {
      setState(() {
        _plantInfo = result ?? "Tanımlama başarısız oldu.";
        _isLoading = false;
      });
    }
  }

  Future<void> _onSaveButtonPressed() async {
    if (!mounted) return;

    if (_predictions.isNotEmpty && _selectedImage != null) {
      final bestPrediction = _predictions[_selectedPredictionIndex];
      final PlantRecord? newRecord = await _showSavePlantDialog(
        image: _selectedImage!,
        plantInfo: {
          'Bitki Adı': bestPrediction.name,
          'Sağlık Durumu': bestPrediction.health,
          'Sulama Sıklığı': bestPrediction.watering,
          'Günün Tavsiyesi': bestPrediction.advice,
          'Işık İhtiyacı': bestPrediction.light,
        },
      );
      if (newRecord != null) {
        await _addPlantToHistory(newRecord);
        if (mounted) {
                // --- YENİ YÖNLENDİRME KODU ---
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PlantSavedPage()),
          );
          // Hatırlatıcı kurma seçeneğini yine de bir SnackBar ile sunabiliriz.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newRecord.nickname} için hatırlatıcı kurulsun mu?'),
              action: SnackBarAction(
                label: 'Evet, Kur',
                onPressed: () => _scheduleAlarm(newRecord),
              ),
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    }
  }

    Future<PlantRecord?> _showSavePlantDialog(
        {required File image, required Map<String, String> plantInfo}) async {
      if (!mounted) return null;

      final nicknameController = TextEditingController();
      const List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever', 'Işık Sever', 'Nemli Toprak Sever'];
      List<String> selectedTags = [];
      return showDialog<PlantRecord>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Bitkinizi Kaydedin'),
            content: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ListBody(
                    children: <Widget>[
                      Text('"${plantInfo['Bitki Adı']}" için bir takma ad belirleyin:'),
                      TextField(
                        controller: nicknameController,
                        decoration: const InputDecoration(hintText: 'Örn: Yeşil Dostum'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Etiketler seçin:'),
                      Wrap(
                        spacing: 8.0,
                        children: availableTags.map((tag) {
                          return FilterChip(
                            label: Text(tag),
                            selected: selectedTags.contains(tag),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) { selectedTags.add(tag); }
                                else { selectedTags.remove(tag); }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.of(dialogContext).pop(null),
              ),
              TextButton(
                child: const Text('Kaydet'),
                onPressed: () {
                  final record = PlantRecord(
                    image: image, plantInfo: plantInfo, date: DateTime.now(),
                    nickname: nicknameController.text.isNotEmpty ? nicknameController.text : plantInfo['Bitki Adı']!,
                    tags: selectedTags,
                  );
                  Navigator.of(dialogContext).pop(record);
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _scheduleAlarm(PlantRecord record) async {
      final BuildContext currentContext = context;

      final Duration? selectedDuration = await showDialog<Duration>(
        context: currentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('${record.nickname} için hatırlatıcı sıklığı seçin'),
            children: <String, Duration>{
              'Bugün': const Duration(days: 0),
              '1 Gün Sonra': const Duration(days: 1),
              '3 Gün Sonra': const Duration(days: 3),
              '1 Hafta Sonra': const Duration(days: 7),
            }.entries.map((entry) {
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(context, entry.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(entry.key),
                ),
              );
            }).toList(),
          );
        },
      );

      if (selectedDuration == null || !currentContext.mounted) return;

      final TimeOfDay? pickedTime = await showTimePicker(
        context: currentContext,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime == null || !currentContext.mounted) return;

      final now = DateTime.now();
      final targetDay = now.add(selectedDuration);
      var scheduledDate = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
        pickedTime.hour,
        pickedTime.minute,
      );

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
      );
      await DatabaseService.instance.insertReminder(newReminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${record.nickname} için hatırlatıcı kuruldu!')),
        );
      }
    }

  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(backgroundColor: Colors.white, body: Center(child: Image.asset('assets/images/logo.png')));
    }
    final pages = [
      MyPlantsPage(plantHistory: _plantHistory, onPlantsUpdated: _refreshPlants),
      HomeScreen(
        selectedImage: _selectedImage,
        plantInfo: _plantInfo,
        isLoading: _isLoading,
        predictions: _predictions,
        selectedPredictionIndex: _selectedPredictionIndex,
        onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
        onClear: () => setState(() {
          _selectedImage = null; _predictions = [];
          _plantInfo = "Tanımam için bana bir bitki göster!";
        }),
        onSave: _onSaveButtonPressed,
        onScheduleReminder: () {},
      ),
    ];
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_pageIndex == 0 ? 'Bitkilerim' : 'Bitki Tanımla'), // Basit metin
        actions: [
          if (_pageIndex == 1 && _predictions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, size: 30),
              tooltip: 'Koleksiyona Kaydet',
              onPressed: _onSaveButtonPressed,
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
        ],
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        items: const <Widget>[
          Icon(Icons.grass_rounded, size: 30, color: Colors.white),
          Icon(Icons.eco_rounded, size: 40, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 1) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      // --- DÜZELTME 1 ---
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(77), // withOpacity(0.3) yerine
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bir Fotoğraf Seçin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildPickerOption(
                          context,
                          icon: Icons.photo_camera_rounded,
                          label: 'Kamera',
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImageAndIdentify(ImageSource.camera);
                          },
                        ),
                        _buildPickerOption(
                          context,
                          icon: Icons.photo_library_rounded,
                          label: 'Galeri',
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImageAndIdentify(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          } else {
            setState(() => _pageIndex = index);
          }
        },
        color: AppTheme.primaryGreen,
        buttonBackgroundColor: AppTheme.primaryGreen,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildPickerOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // --- DÜZELTME 2 ---
                color: Theme.of(context).primaryColor.withAlpha(26), // withOpacity(0.1) yerine
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 32),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}