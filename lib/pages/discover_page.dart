// lib/pages/discover_page.dart (TASARIMA UYGUN, İÇERİK DOLU HALİ)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:plantpal/pages/article_detail_page.dart';
import 'package:plantpal/pages/plant_search_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

// lib/pages/discover_page.dart -> SADECE build metodunu değiştirin

  @override
  Widget build(BuildContext context) {
    // Scaffold ve AppBar'ı kaldırıyoruz çünkü MainScreenShell bunu sağlıyor.
    // Sayfanın kendisi kaydırılabilir olmalı, bu yüzden ListView kullanıyoruz.
    return ListView(
      padding: const EdgeInsets.all(0), // Üstteki boşluğu sıfırla
      children: [
        // --- DÜZELTME BURADA ---
        _buildSearchBar(context), // <-- Fonksiyona context'i gönderiyoruz
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
        _buildArticleCard(context),
        const SizedBox(height: 24),
      ],
    );
  }

  // Arama çubuğunu oluşturan yardımcı fonksiyon
// lib/pages/discover_page.dart -> BU FONKSİYONU GÜNCELLEYİN

Widget _buildSearchBar(BuildContext context) { // <-- context parametresi eklendi
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: GestureDetector(
      onTap: () {
        // Yeni arama sayfasını aç
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlantSearchPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppTheme.secondaryText),
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

  // Kategori başlıklarını oluşturan yardımcı fonksiyon
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

  // Öne çıkan banner'ı oluşturan yardımcı fonksiyon
  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          // --- BU SATIRI DEĞİŞTİRİN ---
          image: AssetImage('assets/images/yeni_baslayanlar_banner.png'), // Kendi dosya adınızı yazın
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

  // Yatay kayan bitki listesini oluşturan yardımcı fonksiyon
  // lib/pages/discover_page.dart -> BU FONKSİYONU TAMAMEN DEĞİŞTİRİN

Widget _buildHorizontalPlantList() {
  // Kendi bitki isimlerinizi ve dosya adlarınızı buraya yazın
  final List<Map<String, String>> popularPlants = [
    {'name': 'Devetabanı', 'image': 'assets/images/deve_tabani.png'},
    {'name': 'Paşa Kılıcı', 'image': 'assets/images/pasa_kilici.png'},
    {'name': 'Orkide', 'image': 'assets/images/orkide.png'},
    {'name': 'Sukulent', 'image': 'assets/images/sukulent.png'},
  ];

  return SizedBox(
    height: 220, // Liste yüksekliği
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: popularPlants.length,
      itemBuilder: (context, index) {
        final plant = popularPlants[index];
        return Container(
          width: 150, // Kart genişliği
          margin: EdgeInsets.only(right: index == popularPlants.length - 1 ? 0 : 16),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset(
                    plant['image']!, // Görseli listeden al
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    plant['name']!, // İsmi listeden al
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
  
  // Bakım rehberi kartını oluşturan yardımcı fonksiyon
  // --- DEĞİŞİKLİK 2: Fonksiyonun artık bir context parametresi almasını sağlıyoruz ---
  Widget _buildArticleCard(BuildContext context) { // <-- 'context' parametresini burada alıyoruz
    return Container(
       margin: const EdgeInsets.symmetric(horizontal: 16.0),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: Colors.grey.withAlpha(52),
             spreadRadius: 2,
             blurRadius: 5,
           )
         ]
       ),
       child: ListTile(
         leading: const Icon(Icons.article_outlined, color: AppTheme.primaryGreen),
         title: Text('Yapraklar Neden Sararır?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
         subtitle: const Text('En yaygın sebepler ve çözümleri'),
         trailing: const Icon(Icons.chevron_right),
         onTap: () {
            Navigator.push(
             context, // <-- Artık 'context' burada tanımlı ve geçerli
             MaterialPageRoute(builder: (context) => const ArticleDetailPage()),
           );
         },
       ),
    );
  }
}