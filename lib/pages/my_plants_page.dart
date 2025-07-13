// lib/pages/my_plants_page.dart (ARAMA VE FİLTRELEME EKLENMİŞ SON HALİ)

import 'package:flutter/material.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/plant_detail_page.dart';
import 'package:plantpal/services/database_service.dart';

class MyPlantsPage extends StatefulWidget {
  final List<PlantRecord> plantHistory;
  final VoidCallback onPlantsUpdated;

  const MyPlantsPage({
    super.key,
    required this.plantHistory,
    required this.onPlantsUpdated,
  });

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {
  String _searchQuery = ''; // Arama metnini tutacak state
  final List<String> _selectedTags = []; // Seçili etiketleri tutacak state

  // Tüm benzersiz etiketleri alacak yardımcı bir getter
  List<String> get _allTags {
    final allTagsSet = <String>{};
    for (var plant in widget.plantHistory) {
      allTagsSet.addAll(plant.tags);
    }
    return allTagsSet.toList()..sort();
  }

  Future<void> _deletePlant(String id) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bitkiyi Sil'),
          content: const Text('Bu bitkiyi koleksiyonunuzdan kalıcı olarak silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Sadece veritabanından değil, buluttan da silmek için servisi kullan
      await DatabaseService.instance.deletePlant(id);
      widget.onPlantsUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    // FİLTRELENMİŞ LİSTEYİ OLUŞTUR
    final filteredPlants = widget.plantHistory.where((plant) {
      // Arama metnine göre filtrele (takma ad içinde ara)
      final matchesSearch = plant.nickname.toLowerCase().contains(_searchQuery.toLowerCase());
      // Etikete göre filtrele (seçili etiket yoksa, hepsini dahil et)
      final matchesTags = _selectedTags.isEmpty || _selectedTags.every((tag) => plant.tags.contains(tag));
      return matchesSearch && matchesTags;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, // Scroll yapınca hemen görünsün
            snap: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 120, // Arama ve filtreleme alanı için yükseklik
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ARAMA ÇUBUĞU
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Bitkilerim içinde ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          // ETİKET FİLTRELERİ
          if (_allTags.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _allTags.length,
                  itemBuilder: (context, index) {
                    final tag = _allTags[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // SONUÇLARI GÖSTEREN GRID
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: widget.plantHistory.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      heightFactor: 5,
                      child: Text('Henüz hiç bitki kaydetmediniz.'),
                    ),
                  )
                : filteredPlants.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          heightFactor: 5,
                          child: Text('Arama kriterlerine uygun bitki bulunamadı.'),
                        ),
                      )
                    : SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final record = filteredPlants[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantDetailPage(record: record),
                                ),
                              ).then((_) => widget.onPlantsUpdated());
                            },
                            onLongPress: () {
                              _deletePlant(record.id);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Image.file(record.image, fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      record.nickname,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}