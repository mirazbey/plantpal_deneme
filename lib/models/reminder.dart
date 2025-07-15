// lib/models/reminder.dart (TEKRARLAMA ÖZELLİĞİ EKLENMİŞ HALİ)

class Reminder {
  final int id;
  final String plantId;
  final String plantNickname;
  final String imagePath;
  final DateTime reminderDate;
  final int intervalDays; // 0 = Tek seferlik, >0 = Tekrarlama günü

  Reminder({
    required this.id,
    required this.plantId,
    required this.plantNickname,
    required this.imagePath,
    required this.reminderDate,
    required this.intervalDays,
  });

  // Veritabanından okumak için
  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      plantId: map['plantId'],
      plantNickname: map['plantNickname'],
      imagePath: map['imagePath'],
      reminderDate: DateTime.parse(map['reminderDate']),
      intervalDays: map['intervalDays'] ?? 0, // Eski kayıtlarda null olabilir
    );
  }

  // Veritabanına yazmak için
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'plantNickname': plantNickname,
      'imagePath': imagePath,
      'reminderDate': reminderDate.toIso8601String(),
      'intervalDays': intervalDays,
    };
  }
}