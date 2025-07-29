// lib/services/image_search_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageSearchService {
  // --- ÖNEMLİ ---
  // Bir önceki adımda aldığınız Unsplash Access Key'i buraya yapıştırın.
  static const String _apiKey = "aCZ0uDbM5Pl2tPH_8QE-mBl57Fa5UiSlhoDO8VCreUY"; 

  static const String _baseUrl = "https://api.unsplash.com/search/photos";

  Future<String?> searchImage(String query) async {
    // Arama sorgusunu daha iyi sonuçlar için optimize edelim
    final optimizedQuery = '$query plant';
    final url = Uri.parse('$_baseUrl?query=$optimizedQuery&per_page=1&client_id=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          // Gelen ilk fotoğrafın küçük versiyonunun URL'sini alıyoruz
          final imageUrl = results[0]['urls']['small'];
          return imageUrl;
        }
      } else {
        debugPrint('Unsplash API isteği başarısız: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Unsplash API hatası: $e');
    }
    return null; // Hata veya sonuç yoksa null döndür
  }
}