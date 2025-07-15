// lib/pages/plant_saved_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantSavedPage extends StatefulWidget {
  const PlantSavedPage({super.key});

  @override
  State<PlantSavedPage> createState() => _PlantSavedPageState();
}

class _PlantSavedPageState extends State<PlantSavedPage> {
  @override
  void initState() {
    super.initState();
    // 4 saniye sonra otomatik olarak bir önceki sayfaya dön
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Büyüyen bitki animasyonu
            Lottie.asset(
              'assets/images/Plant_growing_animation.json',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 24),
            // Animasyonlu yazı
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Koleksiyona Eklendi!',
                  textStyle: GoogleFonts.montserrat( // <-- DEĞİŞTİ
                    fontSize: 28.0, // Boyutu biraz küçültebiliriz
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: false,
            ),
          ],
        ),
      ),
    );
  }
}