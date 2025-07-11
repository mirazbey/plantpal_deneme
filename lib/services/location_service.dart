import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Cihazın mevcut konumunu (enlem ve boylam) alır.
  /// Kullanıcıdan gerekli izinleri de ister.
  Future<Position?> getCurrentLocation() async {
    // 1. Konum servisleri cihazda açık mı diye kontrol et.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Konum servisleri açık değilse, bir hata fırlat.
      // ignore: avoid_print
      print("Konum servisleri kapalı.");
      return null;
    }

    // 2. Konum izninin durumunu kontrol et.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Eğer izin verilmemişse, kullanıcıdan izin iste.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Kullanıcı izni yine reddederse, hata fırlat.
        // ignore: avoid_print
        print("Konum izinleri reddedildi.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kullanıcı izinleri kalıcı olarak engellediyse, hata fırlat.
      // ignore: avoid_print
      print("Konum izinleri kalıcı olarak reddedildi, izinler ayarlardan açılmalı.");
      return null;
    }

    // 3. İzinler tamsa, mevcut konumu al ve geri döndür.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Yüksek doğrulukta istiyoruz
    );
  }
}