// lib/widgets/animated_identification_loader.dart (TAM VE DÜZELTİLMİŞ KOD)

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class AnimatedIdentificationLoader extends StatefulWidget {
  final File selectedImage;

  const AnimatedIdentificationLoader({
    super.key,
    required this.selectedImage,
  });

  @override
  State<AnimatedIdentificationLoader> createState() =>
      _AnimatedIdentificationLoaderState();
}

class _AnimatedIdentificationLoaderState
    extends State<AnimatedIdentificationLoader> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _scanAnimationController;
  late AnimationController _introAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  ui.Image? _leafImage;

  @override
  void initState() {
    super.initState();

    _loadLeafImage();

    _introAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5)
        .animate(CurvedAnimation(parent: _introAnimationController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _introAnimationController, curve: const Interval(0.5, 1.0)));

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Animasyonu yavaşlattım
    )..repeat();

    _videoController = VideoPlayerController.asset('assets/videos/bitki_tanima_ekran.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        _videoController.setVolume(0.0);
        if (mounted) {
          setState(() {}); // Videonun ilk karesini göstermek için
          _introAnimationController.forward();
        }
      });
  }

  Future<void> _loadLeafImage() async {
    // Projenizde assets/images/leaf.png olduğundan emin olun
    final ByteData data = await rootBundle.load('assets/images/leaf.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _leafImage = frame.image;
      });
    }
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
        // 1. Video Arka Planı
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
        
        // 2. Blur Efekti
        ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              color: Colors.black.withAlpha(126),
            ),
          ),
        ),

        // 3. Küçülen Resim Animasyonu
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

        // 4. Sarmaşık Animasyonu ve Metin
        Center(
          child: AnimatedBuilder(
            animation: _introAnimationController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - _fadeAnimation.value,
                child: _introAnimationController.isCompleted
                    ? child
                    : const SizedBox(),
              );
            },
            child: CustomPaint(
              painter: VinePainter(
                animation: _scanAnimationController,
                leafImage: _leafImage,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}


// animated_identification_loader.dart dosyasında, eski VinePainter'ı bununla değiştirin

class VinePainter extends CustomPainter {
  final Animation<double> animation;
  final ui.Image? leafImage; // Sarmaşık resmi

  VinePainter({required this.animation, required this.leafImage})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Metni çizme (Yazı boyutu küçültüldü)
    final textStyle = GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 32, // <-- Yazı boyutunu 36'dan 32'ye düşürdük
        fontWeight: FontWeight.bold,
        shadows: [const Shadow(blurRadius: 8.0, color: Colors.black54)]);
    final textSpan = TextSpan(
      text: "Bitkiniz Analiz Ediliyor...",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width - 40);
    final textOffset = Offset((size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2);
    textPainter.paint(canvas, textOffset);

    // 2. Sarmaşık animasyonu (AKICI VE KESİNTİSİZ YENİ YÖNTEM)
    if (leafImage == null) return;

    // Sarmaşığın döneceği oval yolu tanımla
    final rect = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: textPainter.width + 100,
        height: textPainter.height + 100);
    final path = Path()..addOval(rect);

    // Sarmaşık resminin ne kadar "sık" döşeneceğini belirler. 
    // Değeri artırırsanız sarmaşık deseni daha küçük ve sık görünür.
    const double textureDensity = 2.0; 
    
    // Animasyonun ilerlemesine göre dokunun (sarmaşık resminin) ne kadar kaydırılacağını hesapla
    // Negatif (-) yönde hareket ettirerek saat yönünde dönmesini sağlıyoruz.
    final double offset = -animation.value * leafImage!.width * textureDensity;

    // Sarmaşık resmini bir "doku" gibi kullanmak için ImageShader oluşturuyoruz.
    // Dokuya hareket yanılsaması vermek için bir dönüşüm matrisi uyguluyoruz.
    final Matrix4 matrix = Matrix4.identity()
      ..scale(textureDensity, textureDensity) // Dokunun yoğunluğunu/boyutunu ayarla
      ..translate(offset); // Hesaplanan ofset kadar dokuyu kaydır
      
    final imageShader = ImageShader(
        leafImage!, TileMode.repeated, TileMode.repeated, matrix.storage);

    // Shader'ı kullanacak olan "boya" fırçamızı hazırlıyoruz.
    final vinePaint = Paint()
      ..shader = imageShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0; // Sarmaşığın kalınlığı

    // Son olarak, hazırlanan yolu ve hareketli dokuya sahip boyayı canvas'a çiziyoruz.
    canvas.drawPath(path, vinePaint);
  }

  @override
  bool shouldRepaint(covariant VinePainter oldDelegate) {
    return true; // Animasyonun sürekli güncellenmesi için true döndürüyoruz.
  }
}