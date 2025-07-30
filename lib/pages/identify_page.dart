// lib/pages/identify_page.dart (CORRECTED FINAL CODE)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/pages/light_meter_page.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:plantpal/services/inaturalist_service.dart';
import 'package:plantpal/pages/full_screen_image_page.dart';

class IdentifyPage extends StatefulWidget {
  final File? selectedImage;
  final bool isLoading;
  final List<PlantPrediction> predictions;
  final int selectedPredictionIndex;
  final Function(int) onPredictionSelected;
  final VoidCallback onClear;
  final VoidCallback onSave;

  const IdentifyPage({
    super.key,
    required this.selectedImage,
    required this.isLoading,
    required this.predictions,
    required this.selectedPredictionIndex,
    required this.onPredictionSelected,
    required this.onClear,
    required this.onSave,
  });

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> with TickerProviderStateMixin {
  late TabController _tabController;

 @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.predictions.isEmpty || widget.selectedImage == null) {
      // This part is handled by the AnimatedIdentificationLoader in the parent
      return const Center(child: Text("Sonuçlar Yükleniyor..."));
    }
    final selectedPrediction = widget.predictions[widget.selectedPredictionIndex];

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildImageCollage(context, widget.selectedImage!, selectedPrediction),
                  const SizedBox(height: 24),
                  _buildInfoCard(selectedPrediction),
                  if (widget.predictions.length > 1) ...[
                    const SizedBox(height: 16),
                    _buildPredictionChips(),
                  ],
                  const SizedBox(height: 24),
                  _buildSaveButton(),
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
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Genel Bakış"),
                  Tab(text: "Bitki Kimliği"),
                  Tab(text: "Rehberler"),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, selectedPrediction),
          _buildIdentityTab(selectedPrediction),
          _buildGuidesTab(),
        ],
      ),
    );
  }

  
  // _IdentifyPageState sınıfının içine herhangi bir yere ekle

String _getSummaryKeyword(String fullText, String type) {
  final text = fullText.toLowerCase();
  if (type == 'Işık') {
    if (text.contains('düşük') || text.contains('gölge') || text.contains('az ışık')) return 'Düşük';
    if (text.contains('parlak') || text.contains('bol') || text.contains('doğrudan')) return 'Yüksek';
    return 'Orta';
  }
  if (type == 'Sulama') {
    if (text.contains('az') || text.contains('kurudukça') || text.contains('seyrek')) return 'Az';
    if (text.contains('bol') || text.contains('sık') || text.contains('sürekli nemli')) return 'Bol';
    return 'Orta';
  }
  return 'Orta'; // Varsayılan
}

  Widget _buildOverviewTab(BuildContext context, PlantPrediction prediction) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          prediction.careSummary,
          style: GoogleFonts.montserrat(fontSize: 15, height: 1.6, color: AppTheme.secondaryText),
        ),
        const SizedBox(height: 20),
        _buildQuickInfoPanel(context, prediction),
        const SizedBox(height: 10),
        _buildSectionHeader("Bakım Koşulları"),
        // .toList() kaldırıldı
        ...prediction.careConditions.entries.map((entry) {
          final icon = _getIconForCondition(entry.key);
          return _buildExpansionCard(title: entry.key, content: entry.value, icon: icon);
        }),
      ],
    );
  }

  // identify_page.dart dosyasında, sadece bu fonksiyonu değiştir

Widget _buildIdentityTab(PlantPrediction prediction) {
    final basicInfo = prediction.basicInfo;
    final characteristics = prediction.characteristics;

    // UYARI DÜZELTMESİ: Fonksiyon adı başındaki '_' kaldırıldı.
    Widget buildInfoRow(String title, String? value) {
      if (value == null || value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.montserrat(fontSize: 15, color: AppTheme.secondaryText)),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GoogleFonts.montserrat(fontSize: 15, color: AppTheme.primaryText, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text("Temel Bilgiler", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 17)),
            children: <Widget>[
              // UYARI DÜZELTMESİ: Yeni fonksiyon adı kullanıldı.
              buildInfoRow("Aile", basicInfo['Aile']),
              buildInfoRow("Köken", basicInfo['Köken']),
              buildInfoRow("Bitki Türü", basicInfo['Bitki Türü']),
              buildInfoRow("Yaşam Döngüsü", basicInfo['Yaşam Döngüsü']),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text("Karakteristik Özellikler", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 17)),
            children: <Widget>[
              // UYARI DÜZELTMESİ: Yeni fonksiyon adı kullanıldı.
              buildInfoRow("Bitki Boyu", characteristics['Bitki Boyu']),
              buildInfoRow("Çiçek Yayılımı", characteristics['Çiçek Yayılımı']),
              buildInfoRow("Ekim Zamanı", characteristics['Ekim Zamanı']),
              buildInfoRow("Çiçeklenme", characteristics['Çiçeklenme']),
              buildInfoRow("Meyve", characteristics['Meyve']),
            ],
          ),
        ),
      ],
    );
  }
  


  Widget _buildGuidesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Çok Yakında!", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Bu bitkiye özel ekim, budama ve çoğaltma rehberleri burada yer alacak.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCondition(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('güneş') || condition.contains('ışık')) return Iconsax.sun_1;
    if (condition.contains('sıcaklık')) return Iconsax.activity;
    if (condition.contains('toprak')) return Iconsax.layer;
    if (condition.contains('sulama')) return Iconsax.drop;
    if (condition.contains('gübreleme')) return Iconsax.tree;
    return Iconsax.info_circle;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildExpansionCard({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          Text(content, style: GoogleFonts.montserrat(height: 1.5, color: AppTheme.secondaryText)),
        ],
      ),
    );
  }

  // identify_page.dart dosyasının içinde, _IdentifyPageState class'ının altına ekle

// --- YENİ YARDIMCI WIDGET'LAR ---
Widget _buildPlaceholder() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
  );
}

// _IdentifyPageState sınıfının içinde, bu fonksiyonu tamamen değiştir

Widget _buildNetworkImage(String url, String heroTag) {
  return GestureDetector(
    onTap: () {
      // Tıklandığında tam ekran sayfasına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImagePage(imageUrl: url, heroTag: heroTag),
        ),
      );
    },
    child: Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
          },
        ),
      ),
    ),
  );
}


 // _IdentifyPageState sınıfının içinde, bu fonksiyonu tamamen değiştir

Widget _buildImageCollage(BuildContext context, File userImage, PlantPrediction prediction) {
  final InaturalistService inaturalistService = InaturalistService();

  return SizedBox(
    height: MediaQuery.of(context).size.width * 0.7,
    child: FutureBuilder<List<String>>(
      future: inaturalistService.fetchPlantImages(prediction.scientificName.isEmpty ? prediction.name : prediction.scientificName),
      builder: (context, snapshot) {
        Widget image1 = _buildPlaceholder();
        Widget image2 = _buildPlaceholder();

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
          final imageUrls = snapshot.data!;
          // Gelen ilk iki resmi, benzersiz hero etiketleriyle kullan
          image1 = _buildNetworkImage(imageUrls[0], "image_1");
          if (imageUrls.length > 1) {
            image2 = _buildNetworkImage(imageUrls[1], "image_2");
          } else {
            // Eğer sadece 1 resim geldiyse, ikinci yuvayı boş bırak
            image2 = Container(decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)));
          }
        }
        else if (snapshot.hasError) {
          debugPrint("iNaturalist FutureBuilder hatası: ${snapshot.error}");
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 2, child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(userImage, fit: BoxFit.cover))),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(child: image1),
                  const SizedBox(height: 8),
                  Expanded(child: image2),
                ],
              ),
            ),
          ],
        );
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(prediction.name, style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
          const SizedBox(height: 4),
          if (prediction.scientificName.isNotEmpty)
            Text(prediction.scientificName, style: GoogleFonts.montserrat(fontSize: 16, fontStyle: FontStyle.italic, color: AppTheme.secondaryText)),
        ]),
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

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: widget.onSave,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [AppTheme.primaryGreen, Color.fromARGB(255, 78, 185, 137)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withAlpha(104), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.favorite_border_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Text('Bu Güzelliği Kaydet', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ]),
      ),
    );
  }

  // Bu fonksiyonu tamamen değiştir

Widget _buildQuickInfoPanel(BuildContext context, PlantPrediction prediction) {
  // Yeni fonksiyonu kullanarak özet kelimeleri alıyoruz
  final lightRequirement = _getSummaryKeyword(prediction.careConditions['Güneş Işığı'] ?? '', 'Işık');
  final waterRequirement = _getSummaryKeyword(prediction.careConditions['Sulama'] ?? '', 'Sulama');
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _buildInfoItem(icon: Icons.thermostat_outlined, value: 'Kolay', label: 'Zorluk'),
      // Artık burada "Parlak" yerine "Yüksek", "Toprağın" yerine "Orta" gibi net kelimeler görünecek
      _buildInfoItem(icon: Icons.wb_sunny_outlined, value: lightRequirement, label: 'Işık'),
      _buildInfoItem(icon: Icons.water_drop_outlined, value: waterRequirement, label: 'Sulama'),
      InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LightMeterPage())),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80, height: 90,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withAlpha(40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen),
          ),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.sensors, color: AppTheme.primaryGreen, size: 28),
            SizedBox(height: 8),
            Text('Işık Testi', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      ),
    ],
  );
}
    
  Widget _buildInfoItem({required IconData icon, required String value, required String label}) {
    return Container(
      width: 80, height: 90,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(135),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(180)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: AppTheme.primaryText, size: 28),
        const SizedBox(height: 8),
        Text(value, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryText), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: AppTheme.secondaryText)),
      ]),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}