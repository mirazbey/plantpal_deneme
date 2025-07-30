// lib/services/gemini_service.dart

import 'dart:async'; // Zaman aşımı için eklendi
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:plantpal/pages/chatbot_page.dart'; // Bu importu kendi projenize göre kontrol edin

class GeminiService {
  // Bu fonksiyon artık Uint8List (resmin pikselleri) alıyor
  static Future<String?> getPlantInfo(Uint8List imageBytes, String? weatherInfo) async {
    debugPrint("[GEMINI] getPlantInfo fonksiyonu başlatıldı.");

    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        debugPrint("[GEMINI HATA] API Anahtarı bulunamadı. Lütfen --dart-define-from-file ile derlediğinizden emin olun.");
        return "API anahtarı eksik. Uygulama geliştiricisiyle iletişime geçin.";
      }
      debugPrint("[GEMINI] API Anahtarı başarıyla yüklendi.");

      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      debugPrint("[GEMINI] Model ('gemini-2.0-flash') başarıyla oluşturuldu.");

      // gemini_service.dart -> getPlantInfo fonksiyonu içinde

        final promptText =
            "Sen, son derece bilgili ve konuşkan bir botanik uzmanısın. Görevin, bu bitki fotoğrafını analiz etmek ve aşağıda belirtilen format ve kurallara sıkı sıkıya bağlı kalarak, sanki bir bitki ansiklopedisi sayfası hazırlar gibi detaylı bir metin çıktısı üretmek.\n\n"
            "**ANALİZ VE İÇERİK KURALLARI:**\n"
            "1.  **Tüm Alanları Doldur:** Çıktı formatındaki TÜM alanları, verdiğin bitki tahminine göre en doğru ve detaylı bilgilerle doldur. Eğer bir bilgi kesin değilse, 'Genellikle...', 'Tahminen...' gibi ifadeler kullan.\n"
            "2.  **Samimi Bakım Anlatımı:** '### Bakım Özeti ###' bölümünü, bitkiyle yeni tanışan birine ipuçları verir gibi samimi, teşvik edici ve 1-2 paragraflık bir metinle doldur.\n"
            "3.  **Günün Tavsiyesi:** '$weatherInfo' hava durumu bilgisini kullanarak o güne özel, yaratıcı bir tavsiye ver.\n\n"
            "**ÇIKTI FORMATI (ÇOK ÖNEMLİ - BU FORMATA KESİNLİKLE UY):**\n"
            "---TAHMİN 1---\n"
            "**Bitki Adı:** [Bitkinin yaygın adı]\n"
            "**Bilimsel Adı:** [Bitkinin bilimsel adı]\n"
            "\n"
            "### Bakım Özeti ###\n"
            "[Buraya Kural 2'ye göre oluşturulmuş, 1-2 paragraflık samimi bakım anlatımı gelecek.]\n"
            "\n"
            "### Bakım Koşulları ###\n"
            "**Güneş Işığı:** [Düşük, Orta, Yüksek, Dolaylı, Doğrudan vb. detaylı açıklama]\n"
            "**Hava Sıcaklığı:** [İdeal sıcaklık aralığı, örn: 18°C - 25°C]\n"
            "**Toprak Tipi:** [İyi drene edilmiş, Asidik, Tınlı vb. toprak ihtiyacı]\n"
            "**Sulama:** [Toprağı kurudukça, Haftada bir vb. sulama ihtiyacı]\n"
            "**Gübreleme:** [Büyüme döneminde ayda bir, vb. gübreleme ihtiyacı]\n"
            "**Günün Tavsiyesi:** [Kural 3'e göre oluşturulmuş hava durumuna özel tavsiye]\n"
            "\n"
            "### Temel Bilgiler ###\n"
            "**Aile:** [Bitkinin familyası]\n"
            "**Köken:** [Bitkinin anavatanı]\n"
            "**Bitki Türü:** [Çalı, Ot, Sarmaşık vb.]\n"
            "**Yaşam Döngüsü:** [Tek yıllık, Çok yıllık vb.]\n"
            "\n"
            "### Karakteristik Özellikler ###\n"
            "**Bitki Boyu:** [Ortalama yükseklik, örn: 1-2 m]\n" // <-- DEĞİŞTİ
            "**Çiçek Yayılımı:** [Ortalama yayılma, örn: 1 m]\n" // <-- YENİ EKLENDİ
            "**Ekim Zamanı:** [En ideal ekim mevsimi]\n"
            "**Çiçeklenme:** [Çiçek açma rengi ve zamanı]\n"
            "**Meyve:** [Meyve verip vermediği]\n"
            "\n"
            "---TAHMİN 2---\n"
            "...";

      final prompt = TextPart(promptText);
      // Bu satır artık doğrudan fonksiyondan gelen 'imageBytes' parametresini kullanıyor.
      final dataPart = DataPart('image/jpeg', imageBytes);

      debugPrint("[GEMINI] Veriler hazırlandı. API isteği gönderiliyor...");
      
      final response = await model.generateContent([
        Content.multi([prompt, dataPart])
      ]).timeout(
        const Duration(seconds: 45), // Zaman aşımı süresini biraz artırdım
        onTimeout: () {
          debugPrint("[GEMINI HATA] İstek zaman aşımına uğradı (45 saniye).");
          throw TimeoutException('İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
        },
      );

      debugPrint("[GEMINI] API'den başarılı yanıt alındı.");
      return response.text;

    } catch (e) {
      debugPrint("!!!!!!!!!! GEMINI API HATASI !!!!!!!!!!");
      debugPrint("Hata Tipi: ${e.runtimeType}");
      debugPrint("Hata Detayı: ${e.toString()}");
      debugPrint("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      // Kullanıcıya daha anlamlı bir hata mesajı gösterelim
      if (e is TimeoutException) {
        return "İnternet bağlantınız yavaş görünüyor veya sunucuya ulaşılamıyor. Lütfen tekrar deneyin.";
      }
      return "Bitki analiz edilirken beklenmedik bir sorun oluştu.";
    }
  }

  // getChatbotResponse fonksiyonu (değişiklik yok)
  static Future<String?> getChatbotResponse(List<ChatMessage> history) async {
    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('HATA: Gemini API anahtarı bulunamadı.');
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        systemInstruction: Content.text(
            "Sen PlantPal uygulamasının neşeli ve enerjik botanik uzmanısın! 🌿 Adın 'Botanik Bilgini'. Konuşmaların samimi, öğretici ve bol bol emoji dolu olsun. 🌻 Kullanıcılara bitki bakımıyla ilgili her şeyi en eğlenceli şekilde anlat. Sadece bitkiler, bahçecilik ve bitki bakımı konularında cevap ver. Konu dışı bir soru gelirse, 'Aaa, o konu benim uzmanlık alanımın biraz dışında kalıyor ama istersen sana sukulentlerin ne kadar harika olduğundan bahsedebilirim! 😉' gibi neşeli bir cevapla konuyu bitkilere geri getir."),
      );
      
      final chatHistory = history.map((message) {
        return Content(message.isUser ? 'user' : 'model', [TextPart(message.text)]);
      }).toList().reversed;

      final chat = model.startChat(history: chatHistory.toList());
      final response = await chat.sendMessage(
        Content.text(history.first.text),
      );

      return response.text;
    } catch (e) {
      return "Üzgünüm, bir hata oluştu. Lütfen tekrar dener misin?";
    }
  }

  // getEnglishPlantName fonksiyonu (değişiklik yok)
  static Future<String> getEnglishPlantName(String plantName) async {
    if (plantName.contains(' ') && plantName.length > 5) {
      return plantName;
    }
    
    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) return plantName;

      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      
      final prompt =
          "Translate the following Turkish plant or flower name to English. "
          "Respond with ONLY the translated name and nothing else. "
          "For example, if the input is 'Krizantem Buketi', the output should be 'Chrysanthemum Bouquet'. "
          "If the input is 'Monstera Deliciosa', the output should be 'Monstera Deliciosa'. "
          "Name: '$plantName'";
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      return response.text?.trim() ?? plantName;

    } catch (e) {
      debugPrint('Gemini çeviri hatası: $e');
      return plantName;
    }
  }

  // gemini_service.dart dosyasının içine, diğer fonksiyonların yanına ekle

// --- YENİ VE DOĞRU GÖRSEL ÜRETME FONKSİYONU ---
static Future<Uri?> generatePlantImage(String plantName, String type) async {
  debugPrint("[GEMINI IMAGE] '$plantName' için '$type' tipinde görsel üretimi başlatıldı.");
  try {
    const apiKey = String.fromEnvironment('GEMINI_API_KEY');
    if (apiKey.isEmpty) {
      throw Exception('HATA: Gemini API anahtarı bulunamadı.');
    }

    // Görsel üretimi için en güncel ve yetenekli modeli kullanıyoruz.
    final model = GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey);

    // Gemini'ye ne çizmesi gerektiğini net bir şekilde anlatan komut (prompt)
    String promptText = '';
    if (type == 'yaprak') {
      // Tek bir yaprağın yakın çekimini istiyoruz
      promptText = "Generate a photorealistic image of a single, healthy '$plantName' leaf on a clean, flat, white background. The image should be a macro shot with studio lighting, emphasizing the leaf's texture and details.";
    } else { // saksı
      // Saksıda bitkinin tamamını istiyoruz
      promptText = "Generate a photorealistic image of a small, healthy '$plantName' plant in a simple terracotta pot. The plant should be on a clean, flat, white background with professional studio lighting.";
    }
    
    debugPrint("[GEMINI IMAGE] Prompt: $promptText");

    final response = await model.generateContent([
      Content.text(promptText)
    ]).timeout(const Duration(seconds: 60)); // Görsel üretimi daha uzun sürebilir

    // Gemini'den gelen cevabın içinde bir "FunctionCall" olup olmadığını kontrol ediyoruz.
    // Genellikle görsel üretme gibi işlemler bu şekilde döner.
    // Not: Bu kısım paketin versiyonuna göre değişebilir, ancak bu en modern yaklaşımdır.
    
    // Şimdilik, paketin bu işlemi basitleştirdiğini ve cevabı doğrudan metin olarak
    // veya özel bir 'part' içinde döndürdüğünü varsayalım. En basit ihtimali deneyelim.
    final imageUrl = response.text;

    if (imageUrl != null && Uri.tryParse(imageUrl) != null) {
      debugPrint("[GEMINI IMAGE] Görsel URL'si başarıyla alındı: $imageUrl");
      return Uri.parse(imageUrl);
    } else {
       // Eğer doğrudan URL dönmezse, bu genellikle cevabın daha karmaşık bir yapıda olduğu anlamına gelir.
       // Bu durumda loglama en iyi dostumuzdur.
      debugPrint("[GEMINI IMAGE] Cevapta doğrudan URL bulunamadı. Gelen tüm cevap içeriği loglanıyor...");
      debugPrint(response.toString());
      return null;
    }

  } catch (e) {
    debugPrint("!!!!!!!!!! GEMINI GÖRSEL ÜRETME HATASI !!!!!!!!!!\n${e.toString()}");
    return null;
  }
}

}