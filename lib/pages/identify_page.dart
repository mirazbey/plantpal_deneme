// lib/pages/identify_page.dart (BAĞIMSIZ VE TAM FİNAL KOD)

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/services/database_service.dart';
import 'package:plantpal/services/gemini_service.dart';
import 'package:plantpal/services/location_service.dart';
import 'package:plantpal/services/weather_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:plantpal/services/image_search_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:plantpal/pages/plant_saved_page.dart'; // Bu importu ekle

class IdentifyPage extends StatefulWidget {
  final File imageFile; // Artık sadece bunu alıyor

  const IdentifyPage({super.key, required this.imageFile});

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> with TickerProviderStateMixin {
  // DİKKAT: Tanımlama mantığıyla ilgili tüm state'ler artık burada
  bool _isLoading = true;
  List<PlantPrediction> _predictions = [];
  int _selectedPredictionIndex = 0;
  
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  late AnimationController _textAnimationController;
  late Animation<double> _opacityAnimation;
  late TabController _tabController;
  final ImageSearchService _imageService = ImageSearchService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _videoController = VideoPlayerController.asset('assets/videos/bitki_tanima_ekran.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.setLooping(true);
      _videoController.play();
    });

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _textAnimationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startIdentificationProcess();
    });
  }

  Future<void> _startIdentificationProcess() async {
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
    
    final result = await GeminiService.getPlantInfo(widget.imageFile, weatherString);
    if (!mounted) return;

    if (result != null && result.contains('---TAHMİN')) {
      final predictions = _parsePredictions(result);
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? "Tanımlama başarısız oldu.")));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _textAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "Bitki Tanımlanıyor" : "Tanımlama Sonuçları"),
        centerTitle: true,
        backgroundColor: _isLoading ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.close_square),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: _onSaveButtonPressed,
            )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isLoading) ...[
            _buildLoadingVideo(),
            Container(color: Colors.black.withOpacity(0.3)),
          ],
          if (!_isLoading)
            Container(color: Theme.of(context).scaffoldBackgroundColor),

          if (_isLoading)
            _buildLoadingUI(),

          if (!_isLoading)
            _buildResultsUI(),
        ],
      ),
    );
  }

  // YENİ: ANİMASYONLU YÜKLEME EKRANI
  Widget _buildLoadingAnimation() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video arka planı
        FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              );
            }
            return Container(color: Colors.black);
          },
        ),
        Container(color: Colors.black.withOpacity(0.3)),
        // Yanıp sönen "Analiz Ediliyor" yazısı
        Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              'Bitkiniz Analiz Ediliyor...',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
                shadows: [const Shadow(blurRadius: 10, color: Colors.black54)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SENİN MEVCUT, ÇALIŞAN SONUÇ SAYFAN
  Widget _buildResultsPage() {
    if (widget.predictions.isEmpty || widget.selectedImage == null) {
      // Bu durum, bir hata sonrası boş sonuç geldiğinde olabilir.
      return const Center(child: Text("Tanımlama sonucu bulunamadı."));
    }
    final selectedPrediction = widget.predictions[widget.selectedPredictionIndex];

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  _buildImageCollage(context, widget.selectedImage!, selectedPrediction),
                  const SizedBox(height: 24),
                  _buildInfoCard(selectedPrediction),
                  if (widget.predictions.length > 1) ...[
                    const SizedBox(height: 16),
                    _buildPredictionChips(),
                  ]
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryText,
                indicatorColor: AppTheme.primaryGreen,
                tabs: const [Tab(text: "Bakım"), Tab(text: "Gereksinimler")],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBakimTab(selectedPrediction),
          _buildGereksinimlerTab(selectedPrediction),
        ],
      ),
    );
  }

  Widget _buildImageCollage(BuildContext context, File userImage, PlantPrediction prediction) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.7,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(userImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: _buildUnsplashImage(prediction.name, 1)),
                const SizedBox(height: 8),
                Expanded(child: _buildUnsplashImage(prediction.name, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsplashImage(String query, int index) {
    final searchQuery = index == 2 ? '$query leaf close up' : '$query plant pot';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FutureBuilder<String?>(
        key: ValueKey(searchQuery),
        future: _imageService.searchImage(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(color: Colors.grey.shade200, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.network(snapshot.data!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
          }
          return Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported_outlined, color: Colors.white));
        },
      ),
    );
  }

  Widget _buildInfoCard(PlantPrediction prediction) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prediction.name,
              style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 4),
            if (prediction.scientificName.isNotEmpty)
              Text(
                prediction.scientificName,
                style: GoogleFonts.montserrat(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.secondaryText),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.predictions.length,
        itemBuilder: (context, index) {
          final isSelected = widget.selectedPredictionIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(widget.predictions[index].name),
              selected: isSelected,
              onSelected: (selected) => widget.onPredictionSelected(index),
              selectedColor: AppTheme.primaryGreen,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.primaryText, fontWeight: FontWeight.w600),
              backgroundColor: Colors.white,
              shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBakimTab(PlantPrediction prediction) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      children: [
        _buildDetailRow(Iconsax.ruler, "Zorluk", "Kolay"),
        const Divider(height: 24),
        _buildDetailRow(Iconsax.drop, "Sulama", prediction.watering),
      ],
    );
  }

  Widget _buildGereksinimlerTab(PlantPrediction prediction) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      children: [
        _buildDetailRow(Iconsax.sun_1, "Işık", prediction.light),
        const Divider(height: 24),
        _buildDetailRow(Iconsax.cloud_snow, "Nem", "Orta nem"),
        const Divider(height: 24),
        // DÜZELTME: Iconsax.thermometer yerine Iconsax.sun_1 (veya başka bir ikon)
        _buildDetailRow(Iconsax.sun_1, "Sıcaklık", "18°C - 30°C"),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryText, size: 24),
          const SizedBox(width: 16),
          Text(title, style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.primaryText)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.montserrat(fontSize: 16, color: AppTheme.primaryText, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


// DÜZELTME: _SliverAppBarDelegate sınıfı eksiksiz ve doğru yazıldı
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}