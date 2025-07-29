// lib/pages/article_detail_page.dart (DİNAMİK HALE GETİRİLMİŞ FİNAL KOD)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/models/article_model.dart'; // Modelimizi import ediyoruz
import 'package:plantpal/services/image_search_service.dart'; // Unsplash servisini kullanacağız
import 'package:plantpal/theme/app_theme.dart';

class ArticleDetailPage extends StatelessWidget {
  // DÜZELTME: Bu sayfa artık hangi makaleyi göstereceğini parametre olarak alıyor.
  final Article article;
  final ImageSearchService _imageService = ImageSearchService();

  ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                // DÜZELTME: Başlık artık dinamik olarak 'article' objesinden geliyor.
                article.title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: FutureBuilder<String?>(
                // DÜZELTME: Görseli Unsplash'ten dinamik olarak çekiyoruz.
                future: _imageService.searchImage(article.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      color: Colors.black.withAlpha(80),
                      colorBlendMode: BlendMode.darken,
                    );
                  }
                  // Yüklenirken veya hata durumunda gri bir arka plan göster
                  return Container(color: Colors.grey.shade700);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // DÜZELTME: Başlık yine dinamik olarak geliyor.
                    article.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: AppTheme.secondaryText),
                      SizedBox(width: 4),
                      Text(
                        'Okuma Süresi: 3 dakika', // Bu şimdilik statik kalabilir
                        style: TextStyle(color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    // DÜZELTME: Makale metni, alt başlıktan yola çıkarak genel bir metinle dolduruldu.
                    // İleride bu metni de 'Article' modeline ekleyebilirsin.
                    '${article.subtitle}. Bitki yapraklarının sararması, genellikle "kloroz" olarak adlandırılır ve bitkinin size bir şeylerin yolunda gitmediğini söyleme şeklidir. En yaygın nedenlerden biri aşırı sulamadır...\n\nKökler sürekli su içinde kaldığında yeterli oksijen alamaz ve çürümeye başlayabilir. Bu da bitkinin topraktan besin almasını engeller ve yapraklar sararır.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      height: 1.7,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}