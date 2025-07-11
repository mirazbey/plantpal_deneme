// lib/pages/my_plants_page.dart (GÜNCELLENMİŞ HALİ)

import 'package:flutter/material.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/plant_detail_page.dart';
import 'package:plantpal/services/database_service.dart'; // VERİTABANI SERVİSİ

class MyPlantsPage extends StatefulWidget {
  final List<PlantRecord> plantHistory;
  final VoidCallback onPlantsUpdated; // Geri çağırma fonksiyonu

  const MyPlantsPage({
    super.key, 
    required this.plantHistory,
    required this.onPlantsUpdated, // Yapıcıya ekledik
  });

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {

  // Bitkiyi silme fonksiyonu
  Future<void> _deletePlant(String id) async {
    // Önce bir onay alalım
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bitkiyi Sil'),
          content: const Text('Bu bitkiyi koleksiyonunuzdan kalıcı olarak silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(false), // Silme
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
              onPressed: () => Navigator.of(context).pop(true), // Sil
            ),
          ],
        );
      },
    );

    // Eğer kullanıcı 'Sil' dediyse
    if (shouldDelete == true) {
      await DatabaseService.instance.deletePlant(id);
      // Silme işleminden sonra ana shell'deki listeyi yenilemek için
      // geri çağırma fonksiyonunu tetikle
      widget.onPlantsUpdated(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitkilerim', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: widget.plantHistory.isEmpty
          ? const Center(
              child: Text('Henüz hiç bitki kaydetmediniz.'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.plantHistory.length,
              itemBuilder: (context, index) {
                final record = widget.plantHistory[index];

                return InkWell(
                  // KARTI TIKLANABİLİR YAPIYORUZ
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailPage(record: record),
                      ),
                    );
                  },
                  // UZUN BASMAYI ALGILAMA
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
    );
  }
}