// lib/main_screen_shell.dart (EN SON STABİL ÇALIŞAN VERSİYON)

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
import 'package:plantpal/pages/chatbot_page.dart';
import 'package:plantpal/pages/plant_saved_page.dart';

class MainScreenShell extends StatefulWidget {
  const MainScreenShell({super.key});
  @override
  State<MainScreenShell> createState() => _MainScreenShellState();
}

class _MainScreenShellState extends State<MainScreenShell> with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  int _pageIndex = 1;
  File? _selectedImage;
  String _plantInfo = "Tanımam için bana bir bitki göster!";
  bool _isLoading = false;
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;
  List<PlantRecord> _plantHistory = [];
  
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    if (position == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum kapalı. Daha iyi tavsiyeler için açabilirsiniz.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else if (position != null && mounted) {
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
          'Bitki Adı': bestPrediction.name, 'Sağlık Durumu': bestPrediction.health,
          'Sulama Sıklığı': bestPrediction.watering, 'Günün Tavsiyesi': bestPrediction.advice,
          'Işık İhtiyacı': bestPrediction.light,
        },
      );
      if (newRecord != null) {
        await _addPlantToHistory(newRecord);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PlantSavedPage()),
          );
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
    final currentContext = context;
    if (!currentContext.mounted) return;
    final Map<String, int> reminderOptions = {
      'Tek seferlik (Bugün)': 0, 'Her gün': 1, 'Her 3 günde bir': 3,
      'Her 5 günde bir': 5, 'Haftada bir': 7,
    };
    final int? selectedInterval = await showDialog<int>(
      context: currentContext,
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
    if (selectedInterval == null) return;
    if (!currentContext.mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: currentContext,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    if (!currentContext.mounted) return;
    final intervalDays = selectedInterval;
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await AndroidAlarmManager.oneShotAt(
      scheduledDate, alarmId, fireAlarm,
      exact: true, wakeup: true, allowWhileIdle: true, rescheduleOnReboot: true,
    );
    final newReminder = Reminder(
      id: alarmId, plantId: record.id, plantNickname: record.nickname,
      imagePath: record.image.path, reminderDate: scheduledDate, intervalDays: intervalDays,
    );
    await DatabaseService.instance.insertReminder(newReminder);
    if (currentContext.mounted) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('${record.nickname} için hatırlatıcı kuruldu!')),
      );
    }
  }

  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }
  
  Widget _buildFlashingTextBubble({required VoidCallback onTap}) {
    return FittedBox(
      fit: BoxFit.contain,
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Botanik", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
                  Text("Uzmanı", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(backgroundColor: Colors.white, body: Center(child: Image.asset('assets/images/logo.png')));
    }
    final pages = [
      MyPlantsPage(plantHistory: _plantHistory, onPlantsUpdated: _refreshPlants),
      HomeScreen(
        selectedImage: _selectedImage, plantInfo: _plantInfo, isLoading: _isLoading,
        predictions: _predictions, selectedPredictionIndex: _selectedPredictionIndex,
        onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
        onClear: () => setState(() {
          _selectedImage = null; _predictions = [];
          _plantInfo = "Tanımam için bana bir bitki göster!";
        }),
        onSave: _onSaveButtonPressed,
        onScheduleReminder: () {
           if (_predictions.isNotEmpty && _selectedImage != null) {
             final bestPrediction = _predictions[_selectedPredictionIndex];
             final tempRecord = PlantRecord(
               id: 'temp_${DateTime.now().millisecondsSinceEpoch}', image: _selectedImage!,
               nickname: bestPrediction.name,
               plantInfo: {
                 'Bitki Adı': bestPrediction.name, 'Sağlık Durumu': bestPrediction.health,
                 'Sulama Sıklığı': bestPrediction.watering, 'Günün Tavsiyesi': bestPrediction.advice,
                 'Işık İhtiyacı': bestPrediction.light,
               },
               date: DateTime.now(),
             );
             _scheduleAlarm(tempRecord);
           }
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: _pageIndex == 1
            ? _buildFlashingTextBubble(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotPage()),
                  );
                },
              )
            : null,
        title: Text(_pageIndex == 0 ? 'Bitkilerim' : 'Bitki Tanımla'),
        actions: [
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
                      width: 50, height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(77),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Bir Fotoğraf Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildPickerOption(context, icon: Icons.photo_camera_rounded, label: 'Kamera',
                          onTap: () {
                            Navigator.of(context).pop();
                            _pickImageAndIdentify(ImageSource.camera);
                          },
                        ),
                        _buildPickerOption(context, icon: Icons.photo_library_rounded, label: 'Galeri',
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
                color: Theme.of(context).primaryColor.withAlpha(26),
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