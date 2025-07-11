import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/pages/photo_viewer_page.dart'; // EKSİK OLAN IMPORT
import 'package:plantpal/widgets/info_card.dart';

class HomeScreen extends StatefulWidget {
  final File? selectedImage;
  final String plantInfo;
  final bool isLoading;
  final List<PlantPrediction> predictions;
  final int selectedPredictionIndex;
  final Function(int) onPredictionSelected;
  final VoidCallback onClear;
  final VoidCallback onSave;

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
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedPrediction = widget.predictions.isNotEmpty
        ? widget.predictions[widget.selectedPredictionIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bitki Tanımla', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          if (widget.predictions.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Bitkiyi Kaydet',
              onPressed: widget.onSave,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Ekranı Temizle',
              onPressed: widget.onClear,
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. FOTOĞRAF GÖSTERME ALANI (Düzeltilmiş Hali)
            GestureDetector(
              onTap: () {
                if (widget.selectedImage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewerPage(imageFile: widget.selectedImage!),
                    ),
                  );
                }
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: widget.selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(widget.selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column( // const EKLENDİ
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_search_rounded, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tanımlama için alttaki menüden\nKamera veya Galeri seçin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. SONUÇ BÖLÜMÜ
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (selectedPrediction != null)
              Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.predictions.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(
                              widget.predictions[index].percentage.isNotEmpty
                                  ? '${widget.predictions[index].name} (${widget.predictions[index].percentage})'
                                  : widget.predictions[index].name,
                            ),
                            selected: widget.selectedPredictionIndex == index,
                            onSelected: (selected) {
                              widget.onPredictionSelected(index);
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: widget.selectedPredictionIndex == index ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InfoCard(icon: Icons.eco_rounded, title: 'Bitki Adı', content: selectedPrediction.name),
                  InfoCard(
                    icon: selectedPrediction.health != 'Sağlıklı' ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    title: 'Sağlık Durumu',
                    content: selectedPrediction.health,
                    buttonLabel: selectedPrediction.health != 'Sağlıklı' ? 'Ne yapabilirim?' : 'Çok sağlıklı! 😊',
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
                              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Anladım'))],
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
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(widget.plantInfo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ),
          ],
        ),
      ),
    );
  }
}