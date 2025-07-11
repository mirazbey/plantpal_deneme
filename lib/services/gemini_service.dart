import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static Future<String?> getPlantInfo(File imageFile, String? weatherInfo) async {
    try {
      // API ANAHTARI ARTIK GÜVENLİ BİR ŞEKİLDE DIŞARIDAN ALINIYOR
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY ortam değişkeni bulunamadı.');
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

      final prompt = TextPart(
        "Bu bir bitki fotoğrafı. Bu bitki için en olası 3 tahmini, yüzdeleriyle birlikte, aşağıdaki formatta liste halinde ver. Her tahmin için sağlık durumu, sulama, günün tavsiyesi ve ışık ihtiyacı bilgilerini de ekle. Eğer sadece bir tahminden eminsen, sadece onu ver.\n\n"
        "---TAHMİN 1---\n"
        "**Tahmin Yüzdesi:** [Yüzde]\n"
        "**Bitki Adı:** [Bitkinin yaygın adı]\n"
        "**Sağlık Durumu:** [Hastalık veya 'Sağlıklı']\n"
        "**Tedavi Önerisi:** [Eğer hastalıklıysa, basit bir tedavi önerisi. Sağlıklıysa 'Bakıma devam et' de.]\n"
        "**Sulama Sıklığı:** [Açıklama]\n"
        "**Günün Tavsiyesi:** [Mevcut hava durumu olan '$weatherInfo' için bir tavsiye]\n"
        "**Işık İhtiyacı:** [Düşük, Orta, Yüksek]\n\n"
        "---TAHMİN 2---\n"
        "**Tahmin Yüzdesi:** [Yüzde]\n"
        "**Bitki Adı:** [Bitkinin yaygın adı]\n"
        "..."
      );

      final imageBytes = await imageFile.readAsBytes();
      final dataPart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, dataPart])
      ]);

      return response.text;

    } catch (e) {
      // ignore: avoid_print
      print('Gemini API Hatası: $e');
      if (e.toString().contains('503') || e.toString().contains('overloaded')) {
        return 'Yapay zeka sunucuları şu an çok meşgul. Lütfen daha sonra tekrar deneyin.';
      }
      return 'Bitki tanımlanırken beklenmedik bir hata oluştu.';
    }
  }
}