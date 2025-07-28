// lib/pages/onboarding_page.dart (YENİ VE GÖRSELE UYUMLU HALİ)

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

  // Tanıtım tamamlandığında çalışacak fonksiyon
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true); // Görüldü olarak işaretle
    if (mounted) {
      // Ana ekrana geç ve geri dönmeyi engelle
      // YENİ, DOĞRU HALİ:
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreenShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Görsellerin listesi
    final List<String> imagePaths = [
      'assets/images/2.jpg',
      'assets/images/3.jpg',
      'assets/images/4.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          // Her bir sayfa için tıklama alanları ile birlikte bir katman oluşturuyoruz
          return Stack(
            fit: StackFit.expand, // Stack'in tüm ekranı kaplamasını sağla
            children: [
              // 1. Katman: Arka plan görseli
              Image.asset(
                imagePaths[index],
                fit: BoxFit.contain, // Görselin oranını bozmadan sığdır
              ),

              // 2. Katman: Görünmez Tıklama Alanları
              
              // Eğer son sayfa değilse ("İleri" butonu olanlar)
              if (index < imagePaths.length - 1)
                Positioned(
                  bottom: 110, // Görseldeki "ileri" yazısının yaklaşık konumu (dikey)
                  right: 20,  // Görseldeki "ileri" yazısının yaklaşık konumu (yatay)
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      // Görünmez tıklama alanının boyutu
                      width: 100, 
                      height: 50,
                      color: Colors.red.withAlpha(0), // Alanı tamamen görünmez yap
                    ),
                  ),
                ),

              // Eğer son sayfaysa ("Hadi Başlayalım" butonu olan)
              if (index == imagePaths.length - 1)
                Positioned(
                  // Görseldeki butonun yaklaşık konumunu ve boyutunu ayarlıyoruz
                  // Bunu kendi ekranına göre hassas bir şekilde ayarlayabilirsin.
                  bottom: MediaQuery.of(context).size.height * 0.20, // Ekranın altından %15 yukarıda
                  left: MediaQuery.of(context).size.width * 0.1,    // Ekranın solundan %10 içeride
                  right: MediaQuery.of(context).size.width * 0.1,   // Ekranın sağından %10 içeride
                  child: GestureDetector(
                    onTap: _completeOnboarding,
                    child: Container(
                      height: 60, // Butonun yaklaşık yüksekliği
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(0), // Alanı tamamen görünmez yap
                        borderRadius: BorderRadius.circular(12), // İsteğe bağlı, tıklama alanını yuvarlak yapmak için
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}