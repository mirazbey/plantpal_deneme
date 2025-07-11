// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plantpal/models/plant_record.dart';

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

  // Veritabanı ve tabloları oluşturan fonksiyon
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT'; // nickname ve tags için null olabilir

    await db.execute('''
      CREATE TABLE plants ( 
        id $idType, 
        imagePath $textType,
        plantName $textType,
        health $textType,
        watering $textType,
        advice $textType,
        light $textType,
        date $textType,
        nickname $textTypeNullable,
        tags $textTypeNullable
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}