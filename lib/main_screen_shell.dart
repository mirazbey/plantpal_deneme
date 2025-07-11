// lib/main_screen_shell.dart (NİHAİ TASARIM VE DÜZENLEME)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
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
  int _pageIndex = 1; // 0: Bitkilerim, 1: Ana Ekran (Tanımla)

  // Tanımlama sayfası için durum değişkenleri
  File? _selectedImage;
  String _plantInfo = "Bitkinizi tanımak için aşağıdaki menüden seçim yapın.";
  bool _isLoading = false;
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;

  // Bitkilerim sayfası için durum değişkeni
  List<PlantRecord> _plantHistory = [];
  
  // Fonksiyonların hepsi önceki mesajlardakiyle aynı, değişiklik yok...
  // ...
  // (Burada diğer fonksiyonlarınızın olduğunu varsayıyorum)
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
    // Tanımla sayfasına geçiş yap ve işlemi başlat
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
          await _showNotificationSchedulerDialog(newRecord);
        }
      }
    }
  }

  Future<PlantRecord?> _showSavePlantDialog({required File image, required Map<String, String> plantInfo}) async {
    final nicknameController = TextEditingController();
    const List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever'];
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
              child: const Text('İleri: Hatırlatıcı Kur'),
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
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedDay = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Saat Seç: ${selectedTime.format(context)}'),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
                      if (picked != null) setState(() => selectedTime = picked);
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
                  // ---- ÇÖZÜM BURADA ----
                  
                  // 1. Context'e bağlı nesneleri `await` işleminden ÖNCE yakala
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);
                  
                  // 2. Zaman alan işlemi (bildirim kurma) gerçekleştir
                  await NotificationService().scheduleWeeklyNotification(
                    id: record.id.hashCode,
                    plantName: record.nickname,
                    day: selectedDay,
                    time: selectedTime,
                  );
                  
                  // 3. Artık güvenle yakaladığın nesneleri kullan
                  navigator.pop(); // Diyalogu kapat
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

  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }
  
  Future<void> _refreshPlants() async {
    final plants = await DatabaseService.instance.getAllPlants();
    if (mounted) {
      setState(() {
        _plantHistory = plants;
      });
    }
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
          _selectedImage = null;
          _predictions = [];
          _plantInfo = "Bitkinizi tanımak için aşağıdaki menüden seçim yapın.";
        }),
        onSave: _onSaveButtonPressed,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true, 
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex, // Başlangıçta ana ekran (index 1) seçili
        items: const <Widget>[
          Icon(Icons.grass_rounded, size: 30, color: Colors.white),
          Icon(Icons.eco_rounded, size: 40, color: Colors.white),
          Icon(Icons.photo_library_rounded, size: 30, color: Colors.white),
        ],
        color: AppTheme.primaryGreen,
        buttonBackgroundColor: AppTheme.primaryGreen,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          if (index == 0) { // Bitkilerim
            setState(() => _pageIndex = 0);
          } else if (index == 1) { // Ana Ekran (Tanımla) - Kamera'yı tetikler
            _pickImageAndIdentify(ImageSource.camera);
          } else if (index == 2) { // Galeri
            _pickImageAndIdentify(ImageSource.gallery);
          }
        },
        letIndexChange: (index) => true,
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: pages,
      ),
    );
  }
}