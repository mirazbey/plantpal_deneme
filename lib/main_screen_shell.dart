// lib/main_screen_shell.dart (NİHAİ VE HATASIZ SON HALİ)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantpal/pages/onboarding_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
import 'package:plantpal/pages/settings_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart';
import 'package:plantpal/services/weather_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/alarm_callback.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/pages/chatbot_page.dart';
import 'package:plantpal/pages/plant_saved_page.dart';
import 'package:plantpal/pages/discover_page.dart';
import 'package:plantpal/pages/calendar_page.dart';


class MainScreenShell extends StatefulWidget {
  const MainScreenShell({super.key});
  @override
  State<MainScreenShell> createState() => MainScreenShellState();
}

class MainScreenShellState extends State<MainScreenShell> with SingleTickerProviderStateMixin {
  bool _showSplash = true; 
  int _pageIndex = 0;
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

  void _showAddPlantMenu() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yeni Bitki Ekle',
              style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, size: 30, color: AppTheme.primaryGreen),
              title: Text('Kamerayla Tanımla', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                _pickImageAndIdentify(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, size: 30, color: AppTheme.primaryGreen),
              title: Text('Galeriden Seç', style: GoogleFonts.montserrat(fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                _pickImageAndIdentify(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (hasSeenOnboarding) {
      setState(() => _showSplash = false);
      _refreshPlants();
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        );
      }
    }
  }

  Future<void> _refreshPlants() async {
    final localPlants = await DatabaseService.instance.getAllPlants();
    if (mounted) setState(() => _plantHistory = localPlants);
    final cloudPlants = await DatabaseService.instance.getPlantsFromCloud();
    if (mounted && cloudPlants.isNotEmpty) {
      final allPlants = await DatabaseService.instance.getAllPlants();
      setState(() => _plantHistory = allPlants);
    }
  }
  
  void changePage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

// lib/main_screen_shell.dart -> SADECE build metodunu değiştirin

@override
Widget build(BuildContext context) {
  if (_showSplash) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/logo.png')),
    );
  }

  final pages = [
    MyPlantsPage(plantHistory: _plantHistory, onPlantsUpdated: _refreshPlants, shellState: this),
    const DiscoverPage(),
    const CalendarPage(),
    const SettingsPage(),
  ];

  // --- ANA DÜZELTME BURADA ---
  // Resim seçildiğinde gösterilecek arayüzü belirliyoruz.
  final bool isIdentifying = _selectedImage != null;

  return Scaffold(
      // --- DÜZELTME BURADA ---
      // Arka plan rengini temamızdan alıyoruz.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      extendBody: true, 
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 110,
      // Geri butonu veya yanıp sönen metni duruma göre göster
      leading: isIdentifying
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedImage = null), // Tanımlamadan çık
            )
          : (_pageIndex == 0 ? _buildFlashingTextBubble(onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()));
            }) : null),
      
      title: Text(
        // Başlığı duruma göre ayarla
        isIdentifying ? 'Tanımlama Sonuçları' :
        _pageIndex == 0 ? 'Bitkilerim' :
        _pageIndex == 1 ? 'Keşfet' :
        _pageIndex == 2 ? 'Bakım Takvimi' : 'Ayarlar',
      ),
      actions: [
        // Kaydet butonunu sadece tanımlama ekranındayken göster
        if (isIdentifying && _predictions.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 30),
            tooltip: 'Koleksiyona Kaydet',
            onPressed: _onSaveButtonPressed, // Artık bu fonksiyon kullanılıyor
          ),
      ],
    ),

    // Ana gövdeyi duruma göre değiştiriyoruz
    body: isIdentifying
        ? IdentifyPage( // Resim seçiliyse, Tanımlama Sayfasını göster
            selectedImage: _selectedImage,
            plantInfo: _plantInfo,
            isLoading: _isLoading,
            predictions: _predictions,
            selectedPredictionIndex: _selectedPredictionIndex,
            onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
            onClear: () => setState(() {
              _selectedImage = null;
              _predictions = [];
            }),
            onSave: _onSaveButtonPressed,
          )
        : IndexedStack(index: _pageIndex, children: pages), // Aksi halde ana sayfaları göster

    // Navigasyon barını sadece tanımlama ekranında değilken göster
    bottomNavigationBar: isIdentifying ? null : _buildCustomBottomNav(),
  );
}
 
// lib/main_screen_shell.dart -> ESKİ _buildCustomBottomNav'ı SİLİP BUNU YAPIŞTIRIN
// lib/main_screen_shell.dart -> BU FONKSİYONU GÜNCELLEYİN

Widget _buildCustomBottomNav() {
  return Container(
    height: 85,
    color: Colors.transparent,
    child: Stack(
      children: [
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            height: 65,
            // 'const' anahtar kelimesi BoxDecoration'a eklendi, çünkü içindeki her şey sabit.
            decoration: const BoxDecoration( // <-- 'const' eklendi
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavIcon(
                  icon: Icons.grass_rounded,
                  label: 'Bitkilerim',
                  isSelected: _pageIndex == 0,
                  onTap: () => setState(() => _pageIndex = 0),
                ),
                _NavIcon(
                  icon: Icons.search_rounded,
                  label: 'Keşfet',
                  isSelected: _pageIndex == 1,
                  onTap: () => setState(() => _pageIndex = 1),
                ),
                const SizedBox(width: 60), // <-- Değişmeyen widget'lar için 'const' iyidir.
                _NavIcon(
                  icon: Icons.calendar_today_rounded,
                  label: 'Takvim',
                  isSelected: _pageIndex == 2,
                  onTap: () => setState(() => _pageIndex = 2),
                ),
                _NavIcon(
                  icon: Icons.settings_rounded,
                  label: 'Ayarlar',
                  isSelected: _pageIndex == 3,
                  onTap: () => setState(() => _pageIndex = 3),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: GestureDetector(
            onTap: _showAddPlantMenu, 
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen,
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryGreen.withAlpha(128), blurRadius: 10, spreadRadius: 2),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              // Icon da sabit olduğu için 'const' ekliyoruz.
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 40), // <-- 'const' eklendi
            ),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _pickImageAndIdentify(ImageSource source) async {
    setState(() { _pageIndex = 1; });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImageIdentification(source);
    });
  }

  List<PlantPrediction> _parsePredictions(String rawText) {
    final predictions = <PlantPrediction>[];
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum kapalı. Daha iyi tavsiyeler için açabilirsiniz.'), duration: Duration(seconds: 3)));
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
        _plantInfo = result; _predictions = predictions;
        _selectedPredictionIndex = 0; _isLoading = false;
      });
    } else {
      setState(() {
        _plantInfo = result ?? "Tanımlama başarısız oldu."; _isLoading = false;
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
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PlantSavedPage()));
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newRecord.nickname} için hatırlatıcı kurulsun mu?'),
                action: SnackBarAction(label: 'Evet, Kur', onPressed: () => _scheduleAlarm(newRecord)),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        }
      }
    }
  }

  Future<PlantRecord?> _showSavePlantDialog({required File image, required Map<String, String> plantInfo}) async {
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
            child: StatefulBuilder(builder: (context, setState) {
              return ListBody(
                children: <Widget>[
                  Text('"${plantInfo['Bitki Adı']}" için bir takma ad belirleyin:'),
                  TextField(controller: nicknameController, decoration: const InputDecoration(hintText: 'Örn: Yeşil Dostum')),
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
            }),
          ),
          actions: <Widget>[
            TextButton(child: const Text('İptal'), onPressed: () => Navigator.of(dialogContext).pop(null)),
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
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(entry.key)),
            );
          }).toList(),
        );
      },
    );
    if (selectedInterval == null || !currentContext.mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(context: currentContext, initialTime: TimeOfDay.now());
    if (pickedTime == null || !currentContext.mounted) return;
    final intervalDays = selectedInterval;
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await AndroidAlarmManager.oneShotAt(scheduledDate, alarmId, fireAlarm, exact: true, wakeup: true, allowWhileIdle: true, rescheduleOnReboot: true);
    final newReminder = Reminder(id: alarmId, plantId: record.id, plantNickname: record.nickname, imagePath: record.image.path, reminderDate: scheduledDate, intervalDays: intervalDays);
    await DatabaseService.instance.insertReminder(newReminder);
    if (currentContext.mounted) {
      ScaffoldMessenger.of(currentContext).showSnackBar(SnackBar(content: Text('${record.nickname} için hatırlatıcı kuruldu!')));
    }
  }

  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }

  Widget _buildFlashingTextBubble({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(18)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Botanik", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.1)),
                Text("Uzmanı", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryGreen : AppTheme.accentColor.withAlpha(180);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}