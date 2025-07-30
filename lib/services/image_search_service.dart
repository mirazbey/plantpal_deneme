// lib/services/image_search_service.dart (TAM VE HATASIZ FİNAL KOD)

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:plantpal/models/plant_prediction.dart';
import 'package:plantpal/services/gemini_service.dart';

class ImageSearchService {
  static const String _apiKey = "aCZ0uDbM5Pl2tPH_8QE-mBl57Fa5UiSlhoDO8VCreUY"; 
  static const String _baseUrl = "https://api.unsplash.com/search/photos";

  Future<List<String>> searchPlantImages(PlantPrediction prediction) async {
    // DÜZELTME: Gemini'nin ürettiği bilimsel adı veya normal adı kullanıyoruz.
    final String searchQuery = prediction.scientificName.isNotEmpty 
        ? prediction.scientificName 
        : await GeminiService.getEnglishPlantName(prediction.name);
    
    debugPrint("Unsplash için son arama terimi: '$searchQuery'");

    final List<String> leafImages = await _fetchImages('$searchQuery leaf close up', 1);
    final List<String> potImages = await _fetchImages('$searchQuery plant pot', 1);
    List<String> imageUrls = [...leafImages, ...potImages];
    
    if (imageUrls.length < 2) {
      final List<String> generalImages = await _fetchImages(searchQuery, 2 - imageUrls.length);
      imageUrls.addAll(generalImages);
    }

    if (imageUrls.isEmpty) {
      debugPrint("Hiçbir arama sorgusu için resim bulunamadı.");
      return [];
    }
    return imageUrls;
  }

  Future<String?> searchImage(String query) async {
    final List<String> results = await _fetchImages(query, 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<String>> _fetchImages(String query, int count) async {
    if (query.isEmpty) return [];
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$_baseUrl?query=$encodedQuery&per_page=$count&orientation=squarish&client_id=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results.map<String>((item) => item['urls']['small'] as String).toList();
        }
      }
    } catch (e) {
      debugPrint('Unsplash API hatası: $e');
    }
    return [];
  }
}