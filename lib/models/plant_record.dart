// lib/models/plant_record.dart (BULUTTAN OKUMAYA HAZIR HALİ)

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PlantRecord {
  final String id;
  final File image;
  final Map<String, String> plantInfo;
  final DateTime date;
  String nickname;
  List<String> tags;

  PlantRecord({
    required this.image,
    required this.plantInfo,
    required this.date,
    this.nickname = '',
    this.tags = const [],
    String? id,
  }) : id = id ?? DateTime.now().toIso8601String();

  // YEREL veritabanına yazmak için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': image.path,
      'plantName': plantInfo['Bitki Adı'] ?? '',
      'health': plantInfo['Sağlık Durumu'] ?? '',
      'watering': plantInfo['Sulama Sıklığı'] ?? '',
      'advice': plantInfo['Günün Tavsiyesi'] ?? '',
      'light': plantInfo['Işık İhtiyacı'] ?? '',
      'date': date.toIso8601String(),
      'nickname': nickname,
      'tags': jsonEncode(tags),
    };
  }

  // YEREL veritabanından okunan Map'i nesneye dönüştürür
  static PlantRecord fromMap(Map<String, dynamic> map) {
    return PlantRecord(
      id: map['id'],
      image: File(map['imagePath']),
      plantInfo: {
        'Bitki Adı': map['plantName'],
        'Sağlık Durumu': map['health'],
        'Sulama Sıklığı': map['watering'],
        'Günün Tavsiyesi': map['advice'],
        'Işık İhtiyacı': map['light'],
      },
      date: DateTime.parse(map['date']),
      nickname: map['nickname'] ?? '',
      tags: (jsonDecode(map['tags']) as List<dynamic>).cast<String>(),
    );
  }

  // --- YENİ FONKSİYON ---
  // BULUT veritabanından (Firestore) gelen Map'i nesneye dönüştürür
  static Future<PlantRecord> fromMapCloud(Map<String, dynamic> map) async {
    // Metin (Base64) olarak saklanan resmi alıp tekrar dosyaya dönüştür
    String base64Image = map['imageBase64'];
    final bytes = base64Decode(base64Image);
    final tempDir = await getTemporaryDirectory();
    final imageFile = File(join(tempDir.path, '${map['id']}.jpg'));
    await imageFile.writeAsBytes(bytes);

    // PlantInfo map'ini doğru formata getir
    Map<String, String> info = {};
    if (map['plantInfo'] is Map) {
      (map['plantInfo'] as Map).forEach((key, value) {
        info[key.toString()] = value.toString();
      });
    }

    return PlantRecord(
      id: map['id'],
      image: imageFile, // Yeni oluşturduğumuz dosyayı ata
      plantInfo: info,
      date: DateTime.parse(map['date']),
      nickname: map['nickname'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}