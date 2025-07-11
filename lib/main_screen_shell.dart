// lib/main_screen_shell.dart (TAM VE DÜZELTİLMİŞ HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart'; // DOĞRU YAZIM
import 'package:plantpal/services/weather_service.dart';

class MainScreenShell extends StatefulWidget {
  const MainScreenShell({super.key});

  @override
  State<MainScreenShell> createState() => _MainScreenShellState();
}

class _MainScreenShellState extends State<MainScreenShell> {
  bool _showSplash = true;
  int _selectedIndex = 1;

  File? _selectedImage;
  String _plantInfo = "Tanımlama için alttaki menüden Kamera veya Galeri seçin.";
  bool _isLoading = false;
  
  List<PlantRecord> _plantHistory = []; 
  
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _refreshPlants(); 
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  Future<void> _refreshPlants() async {
    final plants = await DatabaseService.instance.getAllPlants();
    setState(() {
      _plantHistory = plants;
    });
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
        predictions.add(PlantPrediction(
          percentage: percentage, name: name, health: health,
          watering: watering, advice: advice, light: light,
          treatment: treatment,
        ));
      }
    }
    return predictions;
  }

  Future<void> _pickImageAndIdentify(ImageSource source) async {
    setState(() => _selectedIndex = 1);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _plantInfo = "Konum alınıyor...";
        _predictions = [];
      });

      final locationService = LocationService();
      final Position? position = await locationService.getCurrentLocation();
      String? weatherString = "Hava durumu bilgisi alınamadı.";
      if (position != null) {
        setState(() => _plantInfo = "Hava durumu alınıyor...");
        final weatherService = WeatherService();
        final weatherData = await weatherService.getCurrentWeather(position);
        if (weatherData != null) {
          final description = weatherData['weather'][0]['description'];
          final temp = weatherData['main']['temp'];
          weatherString = "$description, $temp °C";
        }
      }
      setState(() => _plantInfo = "Bitki tanınıyor, lütfen bekleyin...");
      final result = await GeminiService.getPlantInfo(_selectedImage!, weatherString);
      
      if (result != null && result.contains('---TAHMİN')) {
        final predictions = _parsePredictions(result);
        if (predictions.isNotEmpty) {        
          setState(() {
            _plantInfo = result;
            _predictions = predictions;
            _selectedPredictionIndex = 0;
            _isLoading = false;
          });
        } else {
          setState(() { _plantInfo = "Sonuçlar anlaşılamadı."; _isLoading = false; });
        }
      } else {
        setState(() {
          _plantInfo = result ?? "Tanımlama başarısız oldu.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSavePlantDialog({required File image, required Map<String, String> plantInfo}) async {
    final nicknameController = TextEditingController();
    final List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever'];
    final List<String> selectedTags = [];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bitkinizi Kaydedin'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Kaydet'),
              onPressed: () {
                final newRecord = PlantRecord(
                  image: image,
                  plantInfo: plantInfo,
                  date: DateTime.now(),
                  nickname: nicknameController.text.isNotEmpty
                      ? nicknameController.text
                      : plantInfo['Bitki Adı']!,
                  tags: selectedTags,
                );
                _addPlantToHistory(newRecord); 
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    _refreshPlants();
  }

  void _onItemTapped(int index) {
    if (index == 0) { // Kamera
      _pickImageAndIdentify(ImageSource.camera);
    } else if (index == 1) { // Galeri
      _pickImageAndIdentify(ImageSource.gallery);
    } else { // Bitkilerim
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Image.asset('assets/images/logo.png')));
    }

    // Ana Ekran ve Bitkilerim sayfası için widget'ları tanımla
    final List<Widget> pageOptions = [
      MyPlantsPage(plantHistory: _plantHistory), // Index 0
      HomeScreen( // Index 1
        selectedImage: _selectedImage,
        plantInfo: _plantInfo,
        isLoading: _isLoading,
        predictions: _predictions,
        selectedPredictionIndex: _selectedPredictionIndex,
        onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
        onClear: () => setState(() {
          _selectedImage = null;
          _predictions = [];
          _plantInfo = "Tanımlama için alttaki menüden Kamera veya Galeri seçin.";
        }),
        onSave: () {
          if (_predictions.isNotEmpty && _selectedImage != null) {
            final bestPrediction = _predictions[_selectedPredictionIndex];
            _showSavePlantDialog(
              image: _selectedImage!,
              plantInfo: {
                'Bitki Adı': bestPrediction.name,
                'Sağlık Durumu': bestPrediction.health,
                'Sulama Sıklığı': bestPrediction.watering,
                'Günün Tavsiyesi': bestPrediction.advice,
                'Işık İhtiyacı': bestPrediction.light,
              },
            );
          }
        },
      ),
    ];

    // Hangi sayfanın gösterileceğini belirle
    Widget currentPage;
    if (_selectedIndex == 2) {
      currentPage = pageOptions[0]; // Bitkilerim
    } else {
      currentPage = pageOptions[1]; // Tanımlama ekranı (Kamera veya Galeri için)
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera_rounded), label: 'Kamera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_rounded), label: 'Galeri'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grass_rounded), label: 'Bitkilerim'),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}