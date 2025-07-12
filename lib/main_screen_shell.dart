// lib/main_screen_shell.dart (NİHAİ, BASİTLEŞTİRİLMİŞ VE HATASIZ HALİ)

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
import 'package:plantpal/services/notification_service.dart';
import 'package:plantpal/services/weather_service.dart';
import 'package:plantpal/theme/app_theme.dart';

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
    final plants = await DatabaseService.instance.getAllPlants();
    if (mounted) {
      setState(() {
        _plantHistory = plants;
      });
    }
  }
  
  // ... (Diğer tüm fonksiyonlarınız burada aynı kalacak, onlara dokunmuyoruz)
  // _parsePredictions, _pickImageAndIdentify, _onSaveButtonPressed vb.
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newRecord.nickname} koleksiyonuna eklendi!')),
          );
        }
      }
    }
  }
  
  Future<PlantRecord?> _showSavePlantDialog({required File image, required Map<String, String> plantInfo}) async {
    final nicknameController = TextEditingController();
    const List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever','Işık Sever','Nemli Toprak Sever'];
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
                  image: image,
                  plantInfo: plantInfo,
                  date: DateTime.now(),
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
  
  // DEĞİŞTİRİLECEK OLAN FONKSİYONUN TAMAMI

Future<void> _showNotificationSchedulerDialog(PlantRecord record) async {
  final Map<int, String> weekdays = {1: 'Pazartesi', 2: 'Salı', 3: 'Çarşamba', 4: 'Perşembe', 5: 'Cuma', 6: 'Cumartesi', 7: 'Pazar'};
  int selectedDay = 1;
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final wateringAdvice = record.plantInfo['Sulama Sıklığı'] ?? 'Tavsiye bulunamadı.';

  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Sulama Hatırlatıcısı Kur'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Yapay Zeka Tavsiyesi:\n\"$wateringAdvice\"", style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 20),
                  const Text('Haftanın hangi günü hatırlatalım?'),
                  DropdownButton<int>(
                    value: selectedDay,
                    isExpanded: true,
                    items: weekdays.entries.map((entry) => DropdownMenuItem<int>(value: entry.key, child: Text(entry.value))).toList(),
                    onChanged: (value) => setState(() => selectedDay = value!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Saat Seç: ${selectedTime.format(context)}'),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('İptal'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Hatırlatıcıyı Kur'),
                onPressed: () async {
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
                  
                  await NotificationService().scheduleWeeklyNotification(
                    id: record.id.hashCode,
                    plantName: record.nickname,
                    day: selectedDay,
                    time: selectedTime,
                  );
                  
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('${record.nickname} için hatırlatıcı kuruldu!')),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}
  
  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }

  // --- build METODU (YENİDEN DÜZENLENDİ) ---

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
          _selectedImage = null;
          _predictions = [];
          _plantInfo = "Tanımam için bana bir bitki göster!";
        }),
        onSave: _onSaveButtonPressed,
        // Baloncuk butonu için callback'iHomeScreen'e geçmiyoruz, çünkü buton artık burada.
        onScheduleReminder: () {}, 
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_pageIndex == 0 ? 'Bitkilerim' : 'Bitki Tanımla', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_pageIndex == 1 && _predictions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.black54, size: 30),
              tooltip: 'Koleksiyona Kaydet',
              onPressed: _onSaveButtonPressed,
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.black54),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
        ],
      ),
      // YENİ YAPI: Ana gövde bir Stack
      body: Stack(
        children: [
          // Arka plandaki asıl sayfa
          IndexedStack(
            index: _pageIndex,
            children: pages,
          ),
          // Sadece "Tanımla" sayfasındayken görünecek olan baloncuk buton
          if (_pageIndex == 1 && _predictions.isNotEmpty && !_isLoading)
            Positioned(
              left: 20,
              bottom: 100, // Navigasyon barından daha yukarıda olması için
              child: InkWell(
                onTap: () {
                  final bestPrediction = _predictions[_selectedPredictionIndex];
                  final tempRecord = PlantRecord(
                    image: _selectedImage!,
                    plantInfo: {'Bitki Adı': bestPrediction.name, 'Sulama Sıklığı': bestPrediction.watering},
                    date: DateTime.now(),
                    nickname: bestPrediction.name,
                  );
                  _showNotificationSchedulerDialog(tempRecord);
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(230),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(38), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Hatırlatıcı Kur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        items: const <Widget>[
          Icon(Icons.grass_rounded, size: 30, color: Colors.white),
          Icon(Icons.eco_rounded, size: 40, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 1) { // Ana Buton (Tanımla) - Kamera veya Galeri sor
            showModalBottomSheet(
              context: context,
              builder: (context) => Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_camera_rounded),
                    title: const Text('Kamera'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImageAndIdentify(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_rounded),
                    title: const Text('Galeri'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImageAndIdentify(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            );
          } else { // Bitkilerim
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
}