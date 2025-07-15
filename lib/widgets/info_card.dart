import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String? buttonLabel; // Opsiyonel buton etiketi
  final VoidCallback? onButtonPressed; // Opsiyonel buton fonksiyonu

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    this.buttonLabel, // Yapıcıya ekledik
    this.onButtonPressed, // Yapıcıya ekledik
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  // <<-- BURASI DEĞİŞTİ (Başlık rengi koyulaştırıldı) -->>
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                // EĞER BİR BUTON İSTENMİŞSE, ONU BURADA GÖSTER
                if (buttonLabel != null && onButtonPressed != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    // <<-- BURASI DEĞİŞTİ (Buton ikonu ve rengi eklendi) -->>
                    child: TextButton.icon(
                      onPressed: onButtonPressed,
                      icon: const Icon(Icons.question_mark_rounded, size: 18), // Soru işareti ikonu
                      label: Text(buttonLabel!),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700, // Okunabilir mavi tonu
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}