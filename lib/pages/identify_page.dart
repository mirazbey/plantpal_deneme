// lib/pages/identify_page.dart (EN SON STABİL ÇALIŞAN VERSİYON)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/pages/photo_viewer_page.dart';
import 'package:plantpal/widgets/info_card.dart';
import 'package:plantpal/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final File? selectedImage;
  final String plantInfo;
  final bool isLoading;
  final List<PlantPrediction> predictions;
  final int selectedPredictionIndex;
  final Function(int) onPredictionSelected;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onScheduleReminder;

  const HomeScreen({
    super.key,
    required this.selectedImage,
    required this.plantInfo,
    required this.isLoading,
    required this.predictions,
    required this.selectedPredictionIndex,
    required this.onPredictionSelected,
    required this.onClear,
    required this.onSave,
    required this.onScheduleReminder,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPrediction =
        predictions.isNotEmpty ? predictions[selectedPredictionIndex] : null;

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (selectedImage == null)
                  Column(
                    children: [
                      Lottie.asset('assets/images/Clear_Day.json', height: 250),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Merhaba! Tanımlamak istediğiniz bitkinin fotoğrafını çekin veya galeriden seçin.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () {
                      if (selectedImage != null) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => PhotoViewerPage(imageFile: selectedImage!)));
                      }
                    },
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(25), spreadRadius: 2, blurRadius: 10)
                        ],
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(selectedImage!, fit: BoxFit.cover)),
                    ),
                  ),
                const SizedBox(height: 24),
                if (isLoading)
                  Column(
                    children: [
                      Lottie.asset('assets/images/Walking_Pothos.json', height: 150),
                      const SizedBox(height: 16),
                      const Text('Bitkiniz analiz ediliyor...',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  )
                else if (selectedPrediction != null)
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(predictions.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(
                                  predictions[index].percentage.isNotEmpty
                                      ? '${predictions[index].name} (${predictions[index].percentage})'
                                      : predictions[index].name,
                                ),
                                selected: selectedPredictionIndex == index,
                                onSelected: (selected) => onPredictionSelected(index),
                                selectedColor: Theme.of(context).primaryColor,
                                labelStyle: TextStyle(
                                  color: selectedPredictionIndex == index
                                      ? Colors.white
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InfoCard(icon: Icons.eco_rounded, title: 'Bitki Adı', content: selectedPrediction.name),
                      InfoCard(
                        icon: selectedPrediction.health != 'Sağlıklı'
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        title: 'Sağlık Durumu',
                        content: selectedPrediction.health,
                        buttonLabel: selectedPrediction.health != 'Sağlıklı'
                            ? 'Ne yapabilirim?'
                            : null,
                        onButtonPressed: selectedPrediction.health != 'Sağlıklı'
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(children: [
                                      Icon(Icons.healing_rounded, color: Colors.orange.shade700),
                                      const SizedBox(width: 10),
                                      const Text('Tedavi Önerisi'),
                                    ]),
                                    content: Text(selectedPrediction.treatment),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Anladım'))
                                    ],
                                  ),
                                );
                              }
                            : null,
                      ),
                      InfoCard(icon: Icons.water_drop_rounded, title: 'Sulama Sıklığı', content: selectedPrediction.watering),
                      InfoCard(icon: Icons.wb_cloudy_rounded, title: 'Günün Tavsiyesi', content: selectedPrediction.advice),
                      InfoCard(icon: Icons.wb_sunny_rounded, title: 'Işık İhtiyacı', content: selectedPrediction.light),
                    ],
                  )
                else if (selectedImage == null)
                  const SizedBox.shrink()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(plantInfo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ),
        if (predictions.isNotEmpty && !isLoading)
          Positioned(
            left: 20,
            bottom: 20,
            child: InkWell(
              onTap: onScheduleReminder,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withAlpha(230),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(38),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Hatırlatıcı Kur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}