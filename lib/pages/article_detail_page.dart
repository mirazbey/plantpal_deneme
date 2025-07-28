// lib/pages/article_detail_page.dart (YENİ SAYFA KODU)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantpal/theme/app_theme.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sayfanın iskeleti, kaydırılabilir bir yapıya sahip
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Üstteki kaybolan başlık ve görsel alanı
          SliverAppBar(
            expandedHeight: 250.0, // Görselin yüksekliği
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Yapraklar Neden Sararır?',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              background: Image.asset(
                // Bu görseli projenize eklemeniz gerekecek
                'assets/images/yellow_leaves_banner.png', 
                fit: BoxFit.cover,
                color: Colors.black.withAlpha(80),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          // Sayfanın geri kalan, kaydırılabilir içeriği
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ana Başlık
                  Text(
                    'Yaprak Sararmasının Yaygın Sebepleri',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Meta Bilgi
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: AppTheme.secondaryText),
                      SizedBox(width: 4),
                      Text(
                        'Okuma Süresi: 3 dakika',
                        style: TextStyle(color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Makale Metni
                  Text(
                    'Bitki yapraklarının sararması, genellikle "kloroz" olarak adlandırılır ve bitkinin size bir şeylerin yolunda gitmediğini söyleme şeklidir. En yaygın nedenlerden biri aşırı sulamadır.\n\nKökler sürekli su içinde kaldığında yeterli oksijen alamaz ve çürümeye başlayabilir. Bu da bitkinin topraktan besin almasını engeller ve yapraklar sararır.\n\nDiğer bir yaygın neden ise besin eksikliğidir. Özellikle nitrojen eksikliği, eski ve alttaki yapraklarda sararmaya yol açar. Bitkinizin toprağı eskidiyse veya uzun süredir gübreleme yapmadıysanız, bu durumla karşılaşabilirsiniz. Işık eksikliği veya tam tersi, doğrudan yakıcı güneşe maruz kalmak da yapraklarda strese ve renk değişimine neden olabilir.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      height: 1.7, // Satır aralığı
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