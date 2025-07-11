import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewerPage extends StatelessWidget {
  final File imageFile;

  const PhotoViewerPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koyu bir arka plan, fotoğrafı öne çıkarır
      backgroundColor: Colors.black,
      // Üstte bir geri butonu olan basit bir AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Geri okunun rengi
      ),
      body: PhotoView(
        imageProvider: FileImage(imageFile),
        // Görüntüleyicinin tüm ekranı kaplamasını sağlar
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}