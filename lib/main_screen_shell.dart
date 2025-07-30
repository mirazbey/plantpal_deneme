// lib/main_screen_shell.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/pages/calendar_page.dart';
import 'package:plantpal/pages/chatbot_page.dart';
import 'package:plantpal/pages/discover_page.dart';
import 'package:plantpal/pages/identify_page.dart';
import 'package:plantpal/pages/my_plants_page.dart';
import 'package:plantpal/pages/onboarding_page.dart';
import 'package:plantpal/pages/plant_saved_page.dart';
import 'package:plantpal/pages/settings_page.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart';
import 'package:plantpal/services/weather_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:plantpal/alarm_callback.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantpal/widgets/animated_identification_loader.dart';

Future<String?> _runGeminiAnalysis(Map<String, dynamic> args) async {
  final Uint8List imageBytes = args['imageBytes'];
  final String weather = args['weather'];
  return await GeminiService.getPlantInfo(imageBytes, weather);
}

class MainScreenShell extends StatefulWidget {
  const MainScreenShell({super.key});
  @override
  State<MainScreenShell> createState() => MainScreenShellState();
}

class MainScreenShellState extends State<MainScreenShell> with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  int _pageIndex = 0;
  List<PlantRecord> _plantHistory = [];
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  
  File? _selectedImage;
  bool _isIdentifying = false;
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 750))..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(backgroundColor: Colors.white, body: Center(child: Image.asset('assets/images/logo.png')));
    }

    final pages = [
      MyPlantsPage(plantHistory: _plantHistory, onPlantsUpdated: _refreshPlants, shellState: this),
      const DiscoverPage(),
      const CalendarPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 110,
        centerTitle: true,
        leading: _isIdentifying
            ? IconButton(icon: const Icon(Icons.close), onPressed: _cancelIdentification)
            : (_pageIndex == 0 ? _buildFlashingTextBubble(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()))) : null),
        title: Text(
          _isIdentifying && _predictions.isNotEmpty ? 'Tanımlama Sonuçları' :
          _isIdentifying && _predictions.isEmpty ? '' :
          _pageIndex == 0 ? 'Bitkilerim' :
          _pageIndex == 1 ? 'Keşfet' :
          _pageIndex == 2 ? 'Bakım Takvimi' : 'Ayarlar',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: const [],
      ),
      body: _isIdentifying
          ? (_predictions.isEmpty
              ? AnimatedIdentificationLoader(selectedImage: _selectedImage!)
              : IdentifyPage(
                  selectedImage: _selectedImage,
                  isLoading: _isIdentifying && _predictions.isEmpty,
                  predictions: _predictions,
                  selectedPredictionIndex: _selectedPredictionIndex,
                  onPredictionSelected: (index) => setState(() => _selectedPredictionIndex = index),
                  onSave: _onSaveButtonPressed,
                  onClear: _cancelIdentification,
                ))
          : IndexedStack(index: _pageIndex, children: pages),
      bottomNavigationBar: _isIdentifying ? null : _buildCustomBottomNav(),
    );
  }

  Future<void> _processImageIdentification(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();

    setState(() {
      _isIdentifying = true;
      _selectedImage = File(pickedFile.path);
      _predictions = [];
    });

    final locationService = LocationService();
    final Position? position = await locationService.getCurrentLocation();
    String weatherString = "Hava durumu bilgisi alınamadı.";
    if (position != null) {
      final weatherService = WeatherService();
      final weatherData = await weatherService.getCurrentWeather(position);
      if (weatherData != null) {
        final description = weatherData['weather'][0]['description'];
        final temp = weatherData['main']['temp'];
        weatherString = "$description, $temp °C";
      }
    }

    final result = await compute(_runGeminiAnalysis, {
      'imageBytes': imageBytes,
      'weather': weatherString,
    });

    if (!mounted) return;
    
    debugPrint("---------- GEMINI'DEN GELEN HAM CEVAP BAŞLANGIÇ ----------");
    debugPrint(result);
    debugPrint("---------- GEMINI'DEN GELEN HAM CEVAP BİTİŞ ----------");


    if (result != null && result.contains('---TAHMİN')) {
      final predictions = _parsePredictions(result);

      // --- UYARI DÜZELTMESİ ---
      debugPrint("[PARSER SONUCU] Toplam $predictions.length adet tahmin bulundu.");

      if (predictions.isNotEmpty) {
        setState(() {
          _predictions = predictions;
          _selectedPredictionIndex = 0;
        });
      } else {
        _cancelIdentification();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cevap anlaşılamadı. Lütfen farklı bir resimle tekrar deneyin.')));
      }
    } else {
      _cancelIdentification();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? 'Tanımlama başarısız oldu.')));
    }
  }
  
  // main_screen_shell.dart dosyasında, sadece bu fonksiyonu değiştir

List<PlantPrediction> _parsePredictions(String rawText) {
  debugPrint("[PARSER] Ayrıştırma işlemi başlatıldı.");
  final predictions = <PlantPrediction>[];
  final parts = rawText.split(RegExp(r'---TAHMİN \d+---'));

  for (var part in parts) {
    if (part.trim().isEmpty) continue;

    // --- DEĞİŞİKLİK: Artık bütün metni baştan temizlemiyoruz ---
    final lines = part.split('\n');
    
    String name = '';
    String scientificName = '';
    String careSummary = '';
    final careConditions = <String, String>{};
    final basicInfo = <String, String>{};
    final characteristics = <String, String>{};

    String currentSection = '';

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('###') && line.endsWith('###')) {
        currentSection = line.replaceAll('###', '').trim();
        debugPrint("[PARSER] Yeni bölüm bulundu: $currentSection");
        continue;
      }

      final keyValuePair = line.split(':');
      if (keyValuePair.length > 1) {
        // --- DEĞİŞİKLİK: Hem ** hem de * işaretlerini burada temizliyoruz ---
        final key = keyValuePair[0].replaceAll('**', '').trim();
        final value = keyValuePair.sublist(1).join(':').replaceAll('**', '').replaceAll('*', '').trim();

        switch (currentSection) {
          case 'Bakım Koşulları':
            careConditions[key] = value;
            break;
          case 'Temel Bilgiler':
            basicInfo[key] = value;
            break;
          case 'Karakteristik Özellikler':
            characteristics[key] = value;
            break;
          default:
            if(key == 'Bitki Adı') name = value;
            if(key == 'Bilimsel Adı') scientificName = value;
            break;
        }
      } else if (currentSection == 'Bakım Özeti') {
        careSummary += '${line.replaceAll('**', '').replaceAll('*', '')}\n';
      }
    }

    if (name.isNotEmpty) {
      debugPrint("[PARSER] '$name' adlı bitki başarıyla ayrıştırıldı. Bilimsel Ad: '$scientificName'");
      predictions.add(PlantPrediction(
        name: name,
        scientificName: scientificName,
        careSummary: careSummary.trim(),
        careConditions: careConditions,
        basicInfo: basicInfo,
        characteristics: characteristics,
      ));
    }
  }
  return predictions;
}

  
  void _showAddPlantMenu() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Yeni Bitki Ekle', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, size: 30, color: AppTheme.primaryGreen),
            title: Text('Kamerayla Tanımla', style: GoogleFonts.montserrat(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              _processImageIdentification(ImageSource.camera);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, size: 30, color: AppTheme.primaryGreen),
            title: Text('Galeriden Seç', style: GoogleFonts.montserrat(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              _processImageIdentification(ImageSource.gallery);
            },
          ),
        ]),
      );
    });
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const OnboardingPage()));
      }
    }
  }

  Future<void> _refreshPlants() async {
    final allPlants = await DatabaseService.instance.getAllPlants();
    if (mounted) setState(() => _plantHistory = allPlants);
  }
  
  void changePage(int index) {
    setState(() => _pageIndex = index);
  }
  
  void _cancelIdentification() {
    setState(() {
      _isIdentifying = false;
      _selectedImage = null;
      _predictions = [];
    });
  }
  
  Future<void> _scheduleAlarm(PlantRecord record) async {
    final currentContext = context;
    if (!currentContext.mounted) return;
    final Map<String, int> reminderOptions = {'Tek seferlik (Bugün)': 0, 'Her gün': 1, 'Her 3 günde bir': 3, 'Her 5 günde bir': 5, 'Haftada bir': 7};
    final int? selectedInterval = await showDialog<int>(context: currentContext, builder: (dialogContext) {
      return SimpleDialog(
        title: Text('${record.nickname} için sulama sıklığı'),
        children: reminderOptions.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, entry.value),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(entry.key)),
          );
        }).toList(),
      );
    });
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

  Future<void> _onSaveButtonPressed() async {
    if (_predictions.isNotEmpty && _selectedImage != null) {
      final bestPrediction = _predictions[_selectedPredictionIndex];
      final Map<String, String> plantInfo = {
        'Bitki Adı': bestPrediction.name,
        'Bilimsel Adı': bestPrediction.scientificName,
        ...bestPrediction.careConditions,
        ...bestPrediction.basicInfo,
        ...bestPrediction.characteristics,
        'Bakım Özeti': bestPrediction.careSummary
      };
      
      final PlantRecord? newRecord = await _showSavePlantDialog(image: _selectedImage!, plantInfo: plantInfo);
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
    final nicknameController = TextEditingController();
    const List<String> availableTags = ['Salon Bitkisi', 'Balkon', 'Az Su İster', 'Gölge Sever', 'Işık Sever', 'Nemli Toprak Sever'];
    List<String> selectedTags = [];
    return showDialog<PlantRecord>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Bitkinizi Kaydedin'),
          content: SingleChildScrollView(child: StatefulBuilder(builder: (context, setState) {
            return ListBody(children: <Widget>[
              Text('"${plantInfo['Bitki Adı']}" için bir takma ad belirleyin:'),
              TextField(controller: nicknameController, decoration: const InputDecoration(hintText: 'Örn: Yeşil Dostum')),
              const SizedBox(height: 20),
              const Text('Etiketler seçin:'),
              Wrap(spacing: 8.0, children: availableTags.map((tag) {
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
              }).toList()),
            ]);
          })),
          actions: <Widget>[
            TextButton(child: const Text('İptal'), onPressed: () => Navigator.of(dialogContext).pop(null)),
            TextButton(child: const Text('Kaydet'), onPressed: () {
              final record = PlantRecord(
                image: image,
                plantInfo: plantInfo,
                date: DateTime.now(),
                nickname: nicknameController.text.isNotEmpty ? nicknameController.text : plantInfo['Bitki Adı']!,
                tags: selectedTags,
              );
              Navigator.of(dialogContext).pop(record);
            }),
          ],
        );
      },
    );
  }
  
  Future<void> _addPlantToHistory(PlantRecord record) async {
    await DatabaseService.instance.insertPlant(record);
    await _refreshPlants();
  }
  
  Widget _buildFlashingTextBubble({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Center(child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(18)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Botanik", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.1)),
            Text("Uzmanı", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.1)),
          ]),
        ),
      )),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 85,
      color: Colors.transparent,
      child: Stack(children: [
        Positioned(left: 0, right: 0, bottom: 0, child: Container(
          height: 65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavIcon(icon: Icons.grass_rounded, label: 'Bitkilerim', isSelected: _pageIndex == 0, onTap: () => setState(() => _pageIndex = 0)),
            _NavIcon(icon: Icons.search_rounded, label: 'Keşfet', isSelected: _pageIndex == 1, onTap: () => setState(() => _pageIndex = 1)),
            const SizedBox(width: 60),
            _NavIcon(icon: Icons.calendar_today_rounded, label: 'Takvim', isSelected: _pageIndex == 2, onTap: () => setState(() => _pageIndex = 2)),
            _NavIcon(icon: Icons.settings_rounded, label: 'Ayarlar', isSelected: _pageIndex == 3, onTap: () => setState(() => _pageIndex = 3)),
          ]),
        )),
        Positioned(top: 0, left: MediaQuery.of(context).size.width / 2 - 35, child: GestureDetector(
          onTap: _showAddPlantMenu, 
          child: Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen,
              boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withAlpha(128), blurRadius: 10, spreadRadius: 2)],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 40),
          ),
        )),
      ]),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.primaryGreen : AppTheme.accentColor.withAlpha(180);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: color, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ]),
      ),
    );
  }
}