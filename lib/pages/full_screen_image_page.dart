// lib/pages/full_screen_image_page.dart (YENİ DOSYA)

import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        // InteractiveViewer, kullanıcının fotoğrafı yakınlaştırmasına ve gezinmesine olanak tanır
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Hero(
            tag: heroTag, // Animasyonlu geçiş için etiket
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}