// lib/pages/discover_page.dart (TAM VE DİNAMİK FİNAL SÜRÜM)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:plantpal/models/article_model.dart';
import 'package:plantpal/pages/plant_search_page.dart';
import 'package:plantpal/services/discover_data_service.dart';
import 'package:plantpal/services/image_search_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:plantpal/pages/article_detail_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late List<PlantSearchResult> _popularPlants;
  late List<Article> _articles;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscoverData();
  }

  void _loadDiscoverData() {
    // Servisten verileri çekiyoruz
    _popularPlants = DiscoverDataService.getPopularPlants();
    _articles = DiscoverDataService.getArticles();
    
    // Veriler yüklendi, yükleme animasyonunu kapat
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSearchBar(context),
        const SizedBox(height: 24),
        _buildSectionTitle('Öne Çıkanlar'),
        const SizedBox(height: 16),
        _buildFeaturedBanner(),
        const SizedBox(height: 24),
        _buildSectionTitle('Popüler Bitkiler'),
        const SizedBox(height: 16),
        _buildHorizontalPlantList(),
        const SizedBox(height: 24),
        _buildSectionTitle('Bakım Rehberleri'),
        const SizedBox(height: 16),
        // DİKKAT: Eski `_buildArticleCard` yerine `_buildArticleList` geldi.
        _buildArticleList(),
        const SizedBox(height: 24),
      ],
    );
  }

  // Arama çubuğu
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlantSearchPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              const Icon(Iconsax.search_normal_1, color: AppTheme.secondaryText),
              const SizedBox(width: 8),
              Text(
                'Bitki veya konu ara...',
                style: GoogleFonts.montserrat(color: AppTheme.secondaryText, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryText,
        ),
      ),
    );
  }
  
  // Öne çıkan banner
  Widget _buildFeaturedBanner() {
    // Bu şimdilik statik kalabilir, ileride bunu da dinamikleştirebiliriz.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/yeni_baslayanlar_banner.png'), // Kendi dosya adını yazın
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(135), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'Yeni Başlayanlar İçin\n5 İdeal Bitki',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dinamik popüler bitkiler listesi
  Widget _buildHorizontalPlantList() {
    final ImageSearchService imageService = ImageSearchService();

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: _popularPlants.length,
        itemBuilder: (context, index) {
          final plant = _popularPlants[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<String?>(
                      future: imageService.searchImage(plant.imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      plant.commonName,
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // DİNAMİK MAKALE LİSTESİ (ESKİ _buildArticleCard yerine)
  Widget _buildArticleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Card(
            child: ListTile(
              leading: const Icon(Iconsax.document_text, color: AppTheme.primaryGreen),
              title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(article.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(article: article),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}