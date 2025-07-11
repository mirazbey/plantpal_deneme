import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>?> getCurrentWeather(Position position) async {
    try {
      // API ANAHTARI ARTIK GÜVENLİ BİR ŞEKİLDE DIŞARIDAN ALINIYOR
      const apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('OPENWEATHER_API_KEY ortam değişkeni bulunamadı.');
      }

      final Uri url = Uri.parse(
          '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=tr');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // ignore: avoid_print
        print('Hava durumu alınamadı. Durum Kodu: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Hava durumu servisi hatası: $e');
      return null;
    }
  }
}