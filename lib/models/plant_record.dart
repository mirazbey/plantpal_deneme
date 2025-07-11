import 'dart:io';

class PlantRecord {
  final String id; // Her kayda özel benzersiz bir kimlik
  final File image;
  final Map<String, String> plantInfo;
  final DateTime date;
  String nickname; // Kullanıcının verdiği takma ad
  List<String> tags; // "Salon Bitkisi", "Kaktüs" gibi etiketler

  PlantRecord({
    required this.image,
    required this.plantInfo,
    required this.date,
    this.nickname = '', // Başlangıçta boş olabilir
    this.tags = const [], // Başlangıçta boş liste
  }) : id = DateTime.now().toIso8601String(); // Kimliği oluşturma zamanına göre ata
}