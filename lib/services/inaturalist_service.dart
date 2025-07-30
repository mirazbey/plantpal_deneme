// lib/services/inaturalist_service.dart (YENİ DOSYA)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class InaturalistService {
  final String _baseUrl = "https://api.inaturalist.org/v1";

  // Bitkinin bilimsel adını kullanarak en iyi görselleri bulur
  Future<List<String>> fetchPlantImages(String scientificName) async {
    // Arama terimindeki 'spp.' gibi ekleri temizleyerek daha iyi sonuç alırız
    final cleanName = scientificName.replaceAll('spp.', '').trim();
    
    try {
      // 1. Adım: Bitki adıyla arama yapıp en iyi takson (tür) sonucunu bul
      final searchUrl = Uri.parse('$_baseUrl/taxa?q=$cleanName&rank=species,genus');
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        debugPrint("iNaturalist arama hatası: ${searchResponse.body}");
        return [];
      }
      
      final searchData = json.decode(searchResponse.body);
      if (searchData['results'] == null || searchData['results'].isEmpty) {
        debugPrint("iNaturalist'te '$cleanName' için sonuç bulunamadı.");
        return [];
      }

      // En iyi sonucun ID'sini al
      final taxonId = searchData['results'][0]['id'];
      
      // 2. Adım: Bulunan ID ile türün detaylarını ve fotoğraflarını çek
      final taxonUrl = Uri.parse('$_baseUrl/taxa/$taxonId');
      final taxonResponse = await http.get(taxonUrl);

      if (taxonResponse.statusCode != 200) {
        debugPrint("iNaturalist takson detayı hatası: ${taxonResponse.body}");
        return [];
      }
      
      final taxonData = json.decode(taxonResponse.body);
      final photos = taxonData['results'][0]['taxon_photos'] as List;

      if (photos.isEmpty) {
        debugPrint("iNaturalist'te '$cleanName' için fotoğraf bulunamadı.");
        return [];
      }
      
      // Fotoğrafların URL'lerini ayıkla (orta boyutlu olanları tercih et)
      final imageUrls = photos
          .map<String>((photo) => photo['photo']['medium_url'] as String)
          .toList();
      
      debugPrint("iNaturalist'ten ${imageUrls.length} adet görsel bulundu.");
      return imageUrls;

    } catch (e) {
      debugPrint("iNaturalist servisinde beklenmedik hata: $e");
      return [];
    }
  }
}