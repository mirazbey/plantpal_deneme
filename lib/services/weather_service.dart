import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:plantpal/api_key.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>?> getCurrentWeather(Position position) async {
    try {
      // API isteği için URL'yi oluşturuyoruz.
      final Uri url = Uri.parse(
          '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$openWeatherApiKey&units=metric&lang=tr');

      // İnternetten veriyi çekiyoruz.
      final response = await http.get(url);

      // Eğer cevap başarılıysa (HTTP 200 kodu),
      if (response.statusCode == 200) {
        // Gelen JSON metnini bir haritaya (Map) dönüştürüp geri döndürüyoruz.
        return jsonDecode(response.body);
      } else {
        // Başarısızsa null döndürüyoruz.
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