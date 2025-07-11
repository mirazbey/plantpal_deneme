import 'package:flutter/material.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/photo_viewer_page.dart';
import 'package:plantpal/widgets/info_card.dart';

class PlantDetailPage extends StatelessWidget {
  final PlantRecord record;

  const PlantDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.nickname, style: Theme.of(context).appBarTheme.titleTextStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewerPage(imageFile: record.image),
                  ),
                );
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 2, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(record.image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Kayıtlı bilgileri InfoCard'lar ile gösteriyoruz
            for (var entry in record.plantInfo.entries)
              InfoCard(
                icon: entry.key == 'Bitki Adı' ? Icons.eco_rounded :
                      entry.key == 'Sağlık Durumu' ? Icons.favorite_rounded :
                      entry.key == 'Sulama Sıklığı' ? Icons.water_drop_rounded :
                      entry.key == 'Günün Tavsiyesi' ? Icons.wb_cloudy_rounded :
                      entry.key == 'Işık İhtiyacı' ? Icons.wb_sunny_rounded :
                      Icons.info_rounded,
                title: entry.key,
                content: entry.value,
              ),
          ],
        ),
      ),
    );
  }
}