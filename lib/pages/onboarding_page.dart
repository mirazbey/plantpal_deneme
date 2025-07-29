// lib/pages/onboarding_page.dart (TABLET UYUMLU, DUYARLI FİNAL KOD)

import 'package:flutter/material.dart';
import 'package:plantpal/main_screen_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreenShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // DÜZELTME: LayoutBuilder ile ekran boyutlarını alıyoruz
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return PageView.builder(
            controller: _pageController,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePaths[index],
                    fit: BoxFit.contain,
                  ),
                  
                  // Eğer son sayfa değilse ("İleri" butonu)
                  if (index < imagePaths.length - 1)
                    Positioned(
                      // DÜZELTME: Sabit '110' yerine ekran yüksekliğinin yüzdesi
                      bottom: screenHeight * 0.15, // Ekranın altından %15 yukarıda
                      // DÜZELTME: Sabit '20' yerine ekran genişliğinin yüzdesi
                      right: screenWidth * 0.05,  // Ekranın sağından %5 içeride
                      child: GestureDetector(
                        onTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          // Boyutları da ekran genişliğine göre ayarlayabiliriz
                          width: screenWidth * 0.25, // Genişliğin %25'i kadar
                          height: screenHeight * 0.07, // Yüksekliğin %7'si kadar
                          color: Colors.transparent, // Tamamen görünmez yap
                        ),
                      ),
                    ),

                  // Eğer son sayfaysa ("Hadi Başlayalım" butonu)
                  if (index == imagePaths.length - 1)
                    Positioned(
                      // Bu kısımdaki yüzdesel kullanımın zaten doğruydu, koruyoruz.
                      bottom: screenHeight * 0.15,
                      left: screenWidth * 0.1,
                      right: screenWidth * 0.1,
                      child: GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          height: screenHeight * 0.08, // Yüksekliği de yüzdesel yapalım
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }
      ),
    );
  }
}