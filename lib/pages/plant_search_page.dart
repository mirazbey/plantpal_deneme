// lib/pages/plant_search_page.dart (TÜM HATALARI GİDERİLMİŞ NİHAİ KOD)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/services/image_search_service.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:plantpal/pages/encyclopedia_detail_page.dart';
import 'package:plantpal/services/plant_data_service.dart';

// Veri yapısı aynı kalıyor
class PlantSearchResult {
  final String commonName;
  final String scientificName;
  final String imagePath;

  PlantSearchResult({
    required this.commonName,
    required this.scientificName,
    required this.imagePath,
  });
}

class PlantSearchPage extends StatefulWidget {
  const PlantSearchPage({super.key});

  @override
  State<PlantSearchPage> createState() => _PlantSearchPageState();
}

class _PlantSearchPageState extends State<PlantSearchPage> {
  final ImageSearchService _imageService = ImageSearchService();

  // HATA 1 DÜZELTMESİ: Eksik değişkenler buraya eklendi.
  List<PlantSearchResult> _allPlants = [];
  List<PlantSearchResult> _filteredResults = [];
  List<PlantSearchResult> _suggestions = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allPlants = PlantDataService.getPlants();

    // Rastgele 3 öneri oluşturma mantığı
    final tempList = _allPlants.toList()..shuffle();
    _suggestions = tempList.take(3).toList();
    
    _filteredResults = [];
    _searchController.addListener(_filterPlants);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredResults = [];
      } else {
        _filteredResults = _allPlants.where((plant) {
          final commonNameMatch = plant.commonName.toLowerCase().contains(query);
          final scientificNameMatch = plant.scientificName.toLowerCase().contains(query);
          return commonNameMatch || scientificNameMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.isNotEmpty;
    // Gösterilecek liste, arama yapılıyorsa filtrelenmiş sonuçlar, yapılmıyorsa önerilerdir.
    final List<PlantSearchResult> listToShow = isSearching ? _filteredResults : _suggestions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryText),
        title: Text('Bitki Ansiklopedisi', style: GoogleFonts.montserrat(color: AppTheme.primaryText, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Bitki adı ara...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // HATA 2 DÜZELTMESİ: Hatalı yorum satırı düzeltildi ve başlık eklendi.
            if (!isSearching && _suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text(
                  'Önerilenler',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText),
                ),
              ),

            Expanded(
              child: ListView.builder(
                // HATA 3 DÜZELTMESİ: Artık doğru liste olan `listToShow` kullanılıyor.
                itemCount: listToShow.length,
                itemBuilder: (context, index) {
                  return _buildSearchResultTile(listToShow[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultTile(PlantSearchResult result) {
    return Card(
      color: Colors.grey.shade200,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EncyclopediaDetailPage(plant: result),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              FutureBuilder<String?>(
                future: _imageService.searchImage(result.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(width: 60, height: 60, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const SizedBox(width: 60, height: 60, child: Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey)));
                  }
                  final imageUrl = snapshot.data!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.commonName, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText)),
                    Text(result.scientificName, style: GoogleFonts.montserrat(fontSize: 14, color: AppTheme.secondaryText)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}