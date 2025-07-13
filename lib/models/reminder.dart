class Reminder {
  final int id; // Veritabanı ve Alarm ID'si olarak kullanılacak
  final String plantId;
  final String plantNickname;
  final String imagePath;
  final DateTime reminderDate;

  Reminder({
    required this.id,
    required this.plantId,
    required this.plantNickname,
    required this.imagePath,
    required this.reminderDate,
  });

  // Veritabanından okumak için
  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      plantId: map['plantId'],
      plantNickname: map['plantNickname'],
      imagePath: map['imagePath'],
      reminderDate: DateTime.parse(map['reminderDate']),
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
    };
  }
}