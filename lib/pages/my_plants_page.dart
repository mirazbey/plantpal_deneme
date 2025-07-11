import 'package:flutter/material.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/plant_detail_page.dart'; // Yeni detay sayfamızı import ediyoruz

class MyPlantsPage extends StatelessWidget {
  final List<PlantRecord> plantHistory;

  const MyPlantsPage({super.key, required this.plantHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bitkilerim', style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: plantHistory.isEmpty
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
              itemCount: plantHistory.length,
              itemBuilder: (context, index) {
                final record = plantHistory[index];

                // Kartları tıklanabilir yapıyoruz
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailPage(record: record),
                      ),
                    );
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
                            record.nickname, // Artık takma adı gösteriyoruz
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