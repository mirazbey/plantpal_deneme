// lib/pages/my_plants_page.dart (NİHAİ VE HATASIZ KOD)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/pages/plant_detail_page.dart';
import 'package:plantpal/theme/app_theme.dart';
import 'package:plantpal/main_screen_shell.dart';

class MyPlantsPage extends StatelessWidget {
  final List<PlantRecord> plantHistory;
  final VoidCallback onPlantsUpdated;
  final MainScreenShellState shellState; // State'e doğrudan erişim için

  const MyPlantsPage({
    super.key,
    required this.plantHistory,
    required this.onPlantsUpdated,
    required this.shellState,
  });

  @override
  Widget build(BuildContext context) {
    if (plantHistory.isEmpty) {
      return EmptyStateView(shellState: shellState);
    }
    return PlantGridView(plantHistory: plantHistory);
  }
}

class PlantGridView extends StatelessWidget {
  final List<PlantRecord> plantHistory;
  const PlantGridView({super.key, required this.plantHistory});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: plantHistory.length,
      itemBuilder: (context, index) {
        final plant = plantHistory[index];
        return PlantCard(plant: plant);
      },
    );
  }
}

class PlantCard extends StatelessWidget {
  final PlantRecord plant;
  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // PlantDetailPage const olamaz çünkü record değişir.
            builder: (context) => PlantDetailPage(record: plant),
          ),
        );
      },
      child: Card( // <-- "const" buradan kaldırıldı.
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.file(plant.image, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.nickname,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // <-- Bu widget sabit olduğu için 'const' kalabilir.
                  Row(
                    children: [
                      const Icon(Icons.water_drop_outlined, size: 14, color: AppTheme.accentColor), // <-- Bu widget sabit.
                      const SizedBox(width: 4), // <-- Bu widget sabit.
                      Text(
                        "Sulama zamanı",
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final MainScreenShellState shellState;
  const EmptyStateView({super.key, required this.shellState});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Henüz hiç bitkin yok.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 28, // Yazıyı biraz büyüttük
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bitkilerini takip etmeye başlamak için bir bitki ekle.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 16),

            // --- DEĞİŞEN KISIM BURASI ---
            // İkon yerine Stack ve Image kullanıyoruz
            Stack(
              alignment: Alignment.center, // Her şeyi ortala
              children: [
                // Katman 1: Arka plan görseli
                Image.asset('assets/images/7_v2.png', width: 400),
                
                // Katman 2: Buton (görselin üzerine gelecek)
                Padding(
                  padding: const EdgeInsets.only(top: 270.0), // Butonu dikeyde biraz aşağı kaydır
                  child: ElevatedButton(
                    onPressed: () {
                      shellState.changePage(1); // Tanımla sayfasına git
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: Text(
                      'İlk bitkini ekle',
                      style: GoogleFonts.montserrat(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}