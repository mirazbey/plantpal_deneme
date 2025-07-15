// lib/services/gemini_service.dart (UZMAN BAHÇIVAN PROMPT'U İLE GÜNCELLENDİ)

import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:plantpal/pages/chatbot_page.dart';

class GeminiService {
  // --- getPlantInfo FONKSİYONU GÜNCELLENDİ ---
  static Future<String?> getPlantInfo(File imageFile, String? weatherInfo) async {
    try {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('HATA: Gemini API anahtarı bulunamadı. Lütfen --dart-define-from-file argümanını kontrol edin.');
      }

      final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
      
      // --- YENİ VE UZMAN TALİMATI ---
      final promptText = 
          "Sen bir uzman bahçıvansın. Görevin, bu bitki fotoğrafını analiz edip, verilen hava durumu bilgisine göre yaratıcı ve gerçekten işe yarar tavsiyeler vermek.\n\n"
          "**ANALİZ VE TAVSİYE KURALLARI:**\n"
          "1.  **'Günün Tavsiyesi' Alanı:** Bu alan en önemlisi. Sana verilen hava durumu '$weatherInfo' bilgisini yorumla.\n"
          "    -   Eğer hava **çok sıcak ve güneşli** ise (örn: 'açık, 30 °C'), bitkinin yapraklarının yanmaması için gölgeye alınması veya su ihtiyacının kontrol edilmesi gerektiğini söyle. Örnek: 'Bugün güneş yakıcı olabilir! ☀️ Yapraklarının zarar görmemesi için onu doğrudan öğle güneşinden korumayı düşünebilirsin.'\n"
          "    -   Eğer hava **yağmurlu** ise, bitki dışarıdaysa toprağının zaten nemli olacağını, bu yüzden fazladan sulama yapmaması gerektiğini hatırlat. Örnek: 'Yağmur bereketi! 🌧️ Eğer bitkin dışarıdaysa, bugün sulama yapmana gerek kalmayabilir. Toprağının nemini kontrol et yeterli.'\n"
          "    -   Eğer hava **soğuk veya rüzgarlı** ise, bitkiyi soğuktan korumak için içeri alması gerektiğini söyle. Örnek: 'Hava biraz serinlemiş gibi 🥶. Eğer hassas bir bitkiyse, bu gece onu soğuktan korunaklı bir yere almak iyi olabilir.'\n"
          "    -   Eğer hava durumu bilgisi yoksa veya 'alınamadı' gibi bir ifade içeriyorsa, o zaman bitkinin genel sağlığıyla ilgili **yaratıcı bir ipucu** ver. Örnek: 'Bugün yapraklarını nemli bir bezle silerek hem tozdan arındırıp daha iyi nefes almasını sağlayabilir, hem de olası zararlıları fark edebilirsin! ✨'\n"
          "2.  Diğer alanları (Bitki Adı, Sağlık, Sulama, Tedavi, Işık) her zamanki gibi doldur.\n\n"
          "**ÇIKTI FORMATI:**\n"
          "---TAHMİN 1---\n"
          "**Tahmin Yüzdesi:** [Yüzde]\n"
          "**Bitki Adı:** [Bitkinin yaygın adı]\n"
          "**Sağlık Durumu:** [Hastalık veya 'Sağlıklı']\n"
          "**Tedavi Önerisi:** [Gerekliyse tedavi, değilse 'Bakıma devam et']\n"
          "**Sulama Sıklığı:** [Genel sulama ihtiyacı]\n"
          "**Günün Tavsiyesi:** [Yukarıdaki kurallara göre oluşturulmuş yaratıcı ve faydalı tavsiye]\n"
          "**Işık İhtiyacı:** [Düşük, Orta, Yüksek]\n"
          "---TAHMİN 2---\n"
          "...";

      final prompt = TextPart(promptText);
      final imageBytes = await imageFile.readAsBytes();
      final dataPart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, dataPart])
      ]);

      return response.text;
    } catch (e) {
      return "Beklenmedik bir hata oluştu:\n\nDetay: ${e.toString()}";
    }
  }

  // getChatbotResponse fonksiyonu aynı kalıyor
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
}