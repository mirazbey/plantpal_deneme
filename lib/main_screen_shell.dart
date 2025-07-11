import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Bu import hatası artık düzelmeli
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart';
import 'package:plantpal/services/weather_service.dart';

// ... (Geri kalan tüm kod aynı kalabilir, ana sorun importlardaydı)
// Önceki mesajda verdiğim tam kod doğruydu, sorun sadece bu dosyanın
// geolocator paketini görememesiydi.
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
  final List<PlantRecord> _plantHistory = [];
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

// main_screen_shell.dart içindeki fonksiyonun yeni hali
List<PlantPrediction> _parsePredictions(String rawText) {
  final List<PlantPrediction> predictions = [];
  final parts = rawText.split(RegExp(r'---TAHMİN \d+---'));

  for (var part in parts) {
    if (part.trim().isEmpty) continue;

    String percentage = '', name = '', health = '', watering = '', advice = '', light = '', treatment = ''; // treatment değişkenini ekledik
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
        case 'Tedavi Önerisi': treatment = value; break; // Yeni bilgiyi okuyoruz
        case 'Sulama Sıklığı': watering = value; break;
        case 'Günün Tavsiyesi': advice = value; break;
        case 'Işık İhtiyacı': light = value; break;
      }
    }
    if (name.isNotEmpty) {
      predictions.add(PlantPrediction(
        percentage: percentage, name: name, health: health,
        watering: watering, advice: advice, light: light,
        treatment: treatment, // Yeni bilgiyi modele ekliyoruz
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
        _predictions = []; // Önceki tahminleri temizle
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
      // ignore: avoid_print
      print("--- GEMINI'DEN GELEN HAM CEVAP ---\n$result\n---------------------------------");
      if (result != null && result.contains('---TAHMİN')) {
        final predictions = _parsePredictions(result);
        // ignore: avoid_print
        print("--- PARÇALANMIŞ TAHMİN SAYISI: ${predictions.length} ---");
        if (predictions.isNotEmpty) {        
          setState(() {
            _plantInfo = result; // Arayüzde tüm tahminleri göstermek için ham metni sakla
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
  // Yeni eklenen diyalog fonksiyonu
Future<void> _showSavePlantDialog({required File image, required Map<String, String> plantInfo}) async {
  final nicknameController = TextEditingController();
  // Gerçek bir uygulamada bu etiketler dinamik olabilir, şimdilik sabit
  final List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever'];
  final List<String> selectedTags = [];

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bitkinizi Kaydedin'),
        content: SingleChildScrollView(
          child: StatefulBuilder( // Diyalog içindeki durumu güncellemek için
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
                          setState(() { // Diyalogun içini yenile
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
              _addPlantToHistory(newRecord); // Ana listeye ekle
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// YENİ EKLENECEK FONKSİYON
void _addPlantToHistory(PlantRecord record) {
  setState(() {
    _plantHistory.insert(0, record);
  });
}

  void _onItemTapped(int index) {
    if (index == 0) {
      // Kamera
      _pickImageAndIdentify(ImageSource.camera);
    } else if (index == 1) {
      // Galeri
      _pickImageAndIdentify(ImageSource.gallery);
    } else if (index == 2) {
      // Bitkilerim
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

          // GÜNCELLENMESİ GEREKEN LİSTE
      final List<Widget> widgetOptions = <Widget>[
        // Kamera ve Galeri için aynı sayfayı kullanıyoruz ve ona GEREKLİ TÜM bilgileri veriyoruz.
        HomeScreen(
          selectedImage: _selectedImage,
          plantInfo: _plantInfo,
          isLoading: _isLoading,
          predictions: _predictions,
          selectedPredictionIndex: _selectedPredictionIndex,
          onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
          // YENİ EKLENEN FONKSİYONLAR
          onClear: () => setState(() {
            _selectedImage = null;
            _predictions = [];
            _plantInfo = "Tanımlama için alttaki menüden Kamera veya Galeri seçin.";
          }),
          onSave: () {
          if (_predictions.isNotEmpty) {
            final bestPrediction = _predictions[_selectedPredictionIndex];
            // Gereksiz değişkeni kaldırıp, bilgiyi doğrudan fonksiyona gönderiyoruz
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
        // Diğer HomeScreen de aynı şekilde güncellenmeli
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
            _plantInfo = "Tanımlama için alttaki menüden Kamera veya Galeri seçin.";
          }),
                onSave: () {
        if (_predictions.isNotEmpty) {
          final bestPrediction = _predictions[_selectedPredictionIndex];
          // Diyalog penceresine bilgiyi doğrudan gönderiyoruz
          _showSavePlantDialog(
            image: _selectedImage!,
            plantInfo: {
              'Bitki Adı': bestPrediction.name, 'Sağlık Durumu': bestPrediction.health,
              'Sulama Sıklığı': bestPrediction.watering, 'Günün Tavsiyesi': bestPrediction.advice,
              'Işık İhtiyacı': bestPrediction.light,
            },
          );
        }
      },
        ),
        MyPlantsPage(plantHistory: _plantHistory),
      ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_camera_rounded), label: 'Kamera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_rounded), label: 'Galeri'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_basket_rounded), label: 'Bitkilerim'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}