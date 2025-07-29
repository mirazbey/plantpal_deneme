// lib/widgets/identification_progress_indicator.dart (GELİŞTİRİLMİŞ FİNAL KOD)
import 'dart:io';
import 'dart:ui'; // BackdropFilter için
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:plantpal/theme/app_theme.dart';

// Enum'lar aynı kalıyor
enum IdentificationStep { location, weather, analysis }
enum StepStatus { waiting, inProgress, completed, error }

class IdentificationProgressIndicator extends StatelessWidget {
  // YENİ: Seçilen resmi alması için File parametresi eklendi
  final File selectedImage;
  
  final IdentificationStep currentStep;
  final StepStatus locationStatus;
  final StepStatus weatherStatus;
  final StepStatus analysisStatus;
  final String? errorMessage; // YENİ: Hata mesajını göstermek için

  const IdentificationProgressIndicator({
    super.key,
    required this.selectedImage,
    required this.currentStep,
    this.locationStatus = StepStatus.waiting,
    this.weatherStatus = StepStatus.waiting,
    this.analysisStatus = StepStatus.waiting,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // KATMAN 1: Bulanıklaştırılmış Arka Plan Görseli
        Image.file(
          selectedImage,
          fit: BoxFit.cover,
        ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withAlpha(78),
            ),
          ),
        ),

        // KATMAN 2: İçerik
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // YENİ: Seçilen fotoğrafın küçük bir önizlemesi
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 3),
                    image: DecorationImage(
                      image: FileImage(selectedImage),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(52),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 40),

                // Adımlar (içerik aynı, stil değişebilir)
                _buildStep(
                  title: 'Konum Bilgisi Alınıyor',
                  status: locationStatus,
                ),
                _buildDivider(),
                _buildStep(
                  title: 'Hava Durumu Analiz Ediliyor',
                  status: weatherStatus,
                ),
                _buildDivider(),
                _buildStep(
                  title: 'Bitki Tanımlanıyor',
                  status: analysisStatus,
                ),

                // YENİ: Hata durumunda mesaj gösterme
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [const Shadow(blurRadius: 2, color: Colors.black)]
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildStep({required String title, required StepStatus status}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: status == StepStatus.waiting ? 0.0 : 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(status),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: status == StepStatus.inProgress ? FontWeight.bold : FontWeight.w500,
                  color: status == StepStatus.error ? Colors.red.shade700 : AppTheme.primaryText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(StepStatus status) {
    switch (status) {
      case StepStatus.inProgress:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryGreen),
        );
      case StepStatus.completed:
        return const Icon(Iconsax.tick_circle, color: Colors.green, size: 24);
      case StepStatus.error:
        return const Icon(Iconsax.close_circle, color: Colors.red, size: 24);
      case StepStatus.waiting:
        return Icon(Iconsax.timer_1, color: Colors.grey.shade400, size: 24);
    }
  }
}