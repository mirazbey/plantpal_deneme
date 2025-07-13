// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/models/reminder.dart';

class DatabaseService {
  // Singleton pattern: Uygulama boyunca bu sınıftan sadece bir tane örnek olmasını sağlar.
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plantpal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

    // database_service.dart içindeki fonksiyonun yeni hali
  Future _createDB(Database db, int version) async {
    // Artık kullanılmayan değişkenleri sildik.
    await db.execute('''
      CREATE TABLE plants ( 
        id TEXT PRIMARY KEY, 
        imagePath TEXT NOT NULL,
        plantName TEXT NOT NULL,
        health TEXT NOT NULL,
        watering TEXT NOT NULL,
        advice TEXT NOT NULL,
        light TEXT NOT NULL,
        date TEXT NOT NULL,
        nickname TEXT,
        tags TEXT
      )
    ''');

    // Yeni hatırlatıcılar tablosu
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY,
        plantId TEXT NOT NULL,
        plantNickname TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        reminderDate TEXT NOT NULL
      )
    ''');
  }

  // Yeni bir bitki kaydını veritabanına ekler
  Future<void> insertPlant(PlantRecord plant) async {
    final db = await instance.database;
    await db.insert('plants', plant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Tüm bitki kayıtlarını veritabanından okur
  Future<List<PlantRecord>> getAllPlants() async {
    final db = await instance.database;
    const orderBy = 'date DESC'; // En son eklenen en üstte olacak şekilde sırala
    final result = await db.query('plants', orderBy: orderBy);
    return result.map((json) => PlantRecord.fromMap(json)).toList();
  }

  // Bir bitkiyi veritabanından siler
  Future<void> deletePlant(String id) async {
    final db = await instance.database;
    await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

    // --- Hatırlatıcı Fonksiyonları ---

  Future<void> insertReminder(Reminder reminder) async {
    final db = await instance.database;
    await db.insert('reminders', reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await instance.database;
    final result = await db.query('reminders', orderBy: 'reminderDate ASC');
    return result.map((json) => Reminder.fromMap(json)).toList();
  }

  Future<void> deleteReminder(int id) async {
    final db = await instance.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}