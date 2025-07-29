// lib/widgets/animated_identification_loader.dart (UYARILARI GİDERİLMİŞ KOD)

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class AnimatedIdentificationLoader extends StatefulWidget {
  final File selectedImage;

  const AnimatedIdentificationLoader({
    super.key,
    required this.selectedImage,
  });

  @override
  State<AnimatedIdentificationLoader> createState() => _AnimatedIdentificationLoaderState();
}

class _AnimatedIdentificationLoaderState extends State<AnimatedIdentificationLoader> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _scanAnimationController;
  late AnimationController _introAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _introAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _introAnimationController, curve: Curves.easeOut)
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _introAnimationController, curve: const Interval(0.5, 1.0))
    );

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _videoController = VideoPlayerController.asset('assets/videos/plant_video.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        _videoController.setVolume(0.0);
        if(mounted) {
          setState(() {}); // Videonun ilk karesini göstermek için
          _introAnimationController.forward();
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scanAnimationController.dispose();
    _introAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_videoController.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
        
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              color: Colors.black.withAlpha(126),
            ),
          ),
        ),

        Center(
          child: AnimatedBuilder(
            animation: _introAnimationController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child: _introAnimationController.isCompleted ? child : const SizedBox(),
              );
            },
            child: CustomPaint(
              painter: TextScanPainter(animation: _scanAnimationController),
              child: const Padding( // DÜZELTME: const eklendi
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Bitkiniz Analiz Ediliyor...",
                  textAlign: TextAlign.center,
                  // DÜZELTME: Stil sabit olduğu için const yapıldı
                  style: TextStyle( /* ... Stil aynı ... */ ),
                ),
              ),
            ),
          ),
        ),

        AnimatedBuilder(
          animation: _introAnimationController,
          builder: (context, child) {
            if (_introAnimationController.isCompleted) {
              return const SizedBox.shrink();
            }
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(widget.selectedImage),
            ),
          ),
        ),
      ],
    );
  }
}
// Metni ve etrafında dönen parlak çizgiyi çizen özel sınıf
class TextScanPainter extends CustomPainter {
  final Animation<double> animation;

  TextScanPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Metni çizmek için hazırlık
    final textStyle = GoogleFonts.orbitron(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: "Bitkiniz Analiz Ediliyor...",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width - 40); // padding'i hesaba kat
    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);

    // 2. Parlak çizgi için hazırlık
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withAlpha(126)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Metnin etrafındaki kutunun (bounding box) boyutları
    final rect = Rect.fromLTWH(textOffset.dx - 20, textOffset.dy - 20, textPainter.width + 40, textPainter.height + 40);
    final path = Path()..addRect(rect);
    final metrics = path.computeMetrics().first;

    // 3. Animasyona göre çizgiyi çiz
    final progress = animation.value;
    final distance = metrics.length * progress;
    final tangent = metrics.getTangentForOffset(distance);

    if (tangent != null) {
      // TextScanPainter -> paint metodu içinde
      const lineLength = 50.0; // Çizginin uzunluğu
      // Çizginin hem önüne hem arkasına doğru uzamasını sağlıyoruz
      final startDistance = distance - lineLength / 2;
      final endDistance = distance + lineLength / 2;
      
      final linePath = metrics.extractPath(startDistance, endDistance);

      canvas.drawPath(linePath, glowPaint); // Önce parlamayı çiz
      canvas.drawPath(linePath, paint);   // Sonra parlak çizgiyi çiz
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}