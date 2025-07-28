// lib/pages/light_meter_page.dart (YENİ SAYFA KODU)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightMeterPage extends StatelessWidget {
  const LightMeterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Işığı öne çıkarmak için koyu tema kullanıyoruz
    return Theme(
      data: ThemeData.dark(), // Sayfaya özel koyu tema
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Işık Ölçer'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Bu ikon sensör verisine göre değişebilir
                const Icon(Icons.wb_sunny, color: Colors.yellow, size: 120),
                const SizedBox(height: 32),
                
                // Teknik Değer
                Text(
                  '5,500 Lüks', // Örnek veri
                  style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),

                // Yorum
                Text(
                  'Parlak Dolaylı Işık', // Örnek veri
                  style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Tavsiye
                Text(
                  'Çoğu salon bitkisi için harika bir seviye!', // Örnek veri
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade300, height: 1.5),
                ),
                const Spacer(),

                // Talimat
                Text(
                  'En doğru sonuç için telefonun sensörünü ışık kaynağına doğru tutun.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}