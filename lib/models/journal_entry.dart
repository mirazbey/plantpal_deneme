// lib/models/journal_entry.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class JournalEntry {
  final String id;
  final String plantId;
  final DateTime date;
  final String note;
  final File? image; // Günlük kaydına eklenen fotoğraf (opsiyonel)
  final String? imageBase64; // Bulut için fotoğrafın metin hali
  final String type; // <-- YENİ EKLENEN ALAN


  JournalEntry({
    required this.id,
    required this.plantId,
    required this.date,
    required this.note,
    this.image,
    this.imageBase64,
    this.type = 'Bakım', // <-- Varsayılan değer olarak 'Bakım' atandı

  });

  // Yerel veritabanına yazmak için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'date': date.toIso8601String(),
      'note': note,
      'imagePath': image?.path, // Sadece dosya yolunu kaydet
      'type': type, // <-- Veritabanına eklemek için

    };
  }

  // Yerel veritabanından okunan Map'i nesneye dönüştürür
  static JournalEntry fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      plantId: map['plantId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      // Eğer bir resim yolu kaydedilmişse, onu File nesnesine dönüştür
      image: map['imagePath'] != null ? File(map['imagePath']) : null,
      type: map['type'] ?? 'Bakım', // <-- Veritabanından okumak için
      
    );
  }

    // Bulut (Firestore) veritabanından gelen Map'i nesneye dönüştürür
  static Future<JournalEntry> fromMapCloud(Map<String, dynamic> map) async {
    File? imageFile;
    if (map['imageBase64'] != null && map['imageBase64'].isNotEmpty) {
      final bytes = base64Decode(map['imageBase64']);
      final tempDir = await getTemporaryDirectory();
      imageFile = File(join(tempDir.path, 'journal_${map['id']}.jpg'));
      await imageFile.writeAsBytes(bytes);
    }

    return JournalEntry(
      id: map['id'],
      plantId: map['plantId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      image: imageFile,
      imageBase64: map['imageBase64'],
    );
  }
}