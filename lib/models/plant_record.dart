// lib/models/plant_record.dart

import 'dart:convert'; // JSON işlemleri için
import 'dart:io';

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
    String? id, // ID artık opsiyonel
  }) : id = id ?? DateTime.now().toIso8601String(); // Eğer ID verilmezse yeni bir tane oluştur

  // Nesneyi veritabanına yazmak için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': image.path, // Resmin dosya yolunu kaydediyoruz
      'plantName': plantInfo['Bitki Adı'] ?? '',
      'health': plantInfo['Sağlık Durumu'] ?? '',
      'watering': plantInfo['Sulama Sıklığı'] ?? '',
      'advice': plantInfo['Günün Tavsiyesi'] ?? '',
      'light': plantInfo['Işık İhtiyacı'] ?? '',
      'date': date.toIso8601String(),
      'nickname': nickname,
      'tags': jsonEncode(tags), // Etiket listesini JSON metnine çeviriyoruz
    };
  }

  // Veritabanından okunan Map'i nesneye dönüştürür
  static PlantRecord fromMap(Map<String, dynamic> map) {
    return PlantRecord(
      id: map['id'],
      image: File(map['imagePath']), // Kaydettiğimiz yoldan dosyayı yüklüyoruz
      plantInfo: {
        'Bitki Adı': map['plantName'],
        'Sağlık Durumu': map['health'],
        'Sulama Sıklığı': map['watering'],
        'Günün Tavsiyesi': map['advice'],
        'Işık İhtiyacı': map['light'],
      },
      date: DateTime.parse(map['date']),
      nickname: map['nickname'] ?? '',
      tags: (jsonDecode(map['tags']) as List<dynamic>).cast<String>(), // JSON metnini listeye çeviriyoruz
    );
  }
}