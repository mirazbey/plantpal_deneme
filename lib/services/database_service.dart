// lib/services/database_service.dart (HATALARI DÜZELTİLMİŞ HALİ)

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // print yerine debugPrint için
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:plantpal/models/plant_record.dart';
import 'package:plantpal/models/reminder.dart';
import 'package:plantpal/models/journal_entry.dart'; // <-- HATA GİDEREN SATIR

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  DatabaseService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('plantpal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Veritabanı sürümünü 2'ye çıkarıyoruz çünkü yeni bir tablo ekledik.
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE plants ( 
        id TEXT PRIMARY KEY, imagePath TEXT NOT NULL, plantName TEXT NOT NULL,
        health TEXT NOT NULL, watering TEXT NOT NULL, advice TEXT NOT NULL,
        light TEXT NOT NULL, date TEXT NOT NULL, nickname TEXT, tags TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY, plantId TEXT NOT NULL, plantNickname TEXT NOT NULL,
        imagePath TEXT NOT NULL, reminderDate TEXT NOT NULL
      )
    ''');
    // --- YENİ EKLENEN TABLO ---
    await _createJournalTable(db);
  }

  // --- YENİ: Yükseltme Fonksiyonu ---
  // Uygulama güncellendiğinde veritabanı şemasını da günceller.
  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createJournalTable(db);
    }
  }

  Future<void> _createJournalTable(Database db) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        plantId TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL,
        imagePath TEXT
      )
    ''');
  }


  Future<void> insertPlant(PlantRecord plant) async {
    final db = await instance.database;
    await db.insert('plants', plant.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
          plant.image.absolute.path,
          minWidth: 400,
          minHeight: 400,
          quality: 70,
        );
        if (compressedBytes != null) {
          String base64Image = base64Encode(compressedBytes);
          var plantDataForCloud = {
            'id': plant.id, 'plantInfo': plant.plantInfo, 'date': plant.date.toIso8601String(),
            'nickname': plant.nickname, 'tags': plant.tags, 'imageBase64': base64Image,
          };
          await _firestore.collection('users').doc(user.uid).collection('plants').doc(plant.id).set(plantDataForCloud);
        }
      } catch (e) {
        debugPrint("Buluta bitki ekleme hatası: $e");
      }
    }
  }

  Future<void> deletePlant(String id) async {
    final db = await instance.database;
    await db.delete('plants', where: 'id = ?', whereArgs: [id]);
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).collection('plants').doc(id).delete();
      } catch (e) {
        debugPrint("Buluttan silme hatası: $e");
      }
    }
  }

  // ... diğer fonksiyonlar (getAllPlants, insertReminder, vb.) aynı kalabilir ...
  Future<List<PlantRecord>> getAllPlants() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query('plants', orderBy: orderBy);
    return result.map((json) => PlantRecord.fromMap(json)).toList();
  }
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
  Future<List<PlantRecord>> getPlantsFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('plants').get();
      if (snapshot.docs.isEmpty) return [];
      final plantRecords = await Future.wait(snapshot.docs.map((doc) => PlantRecord.fromMapCloud(doc.data())));
      for (var record in plantRecords) {
        await insertPlant(record);
      }
      return plantRecords.toList();
    } catch (e) {
      debugPrint("Buluttan bitki getirme hatası: $e");
      return [];
    }
  }


  // --- YENİ FONKSİYONLAR ---
  Future<void> addJournalEntry(JournalEntry entry) async {
    final db = await instance.database;
    await db.insert('journal_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    final user = _auth.currentUser;
    if (user != null) {
      try {
        String? base64Image;
        if (entry.image != null) {
          final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
            entry.image!.absolute.path,
            minWidth: 400,
            minHeight: 400,
            quality: 70,
          );
          if (compressedBytes != null) {
            base64Image = base64Encode(compressedBytes);
          }
        }
        var entryDataForCloud = {
          'id': entry.id, 'plantId': entry.plantId, 'date': entry.date.toIso8601String(),
          'note': entry.note, 'imageBase64': base64Image,
        };
        await _firestore.collection('users').doc(user.uid).collection('plants').doc(entry.plantId)
            .collection('journal_entries').doc(entry.id).set(entryDataForCloud);
      } catch (e) {
        debugPrint("Günlük kaydı buluta eklenemedi: $e");
      }
    }
  }

  Future<List<JournalEntry>> getJournalEntries(String plantId) async {
    final db = await instance.database;
    final localResult = await db.query('journal_entries', where: 'plantId = ?', whereArgs: [plantId], orderBy: 'date DESC');
    List<JournalEntry> entries = localResult.map((json) => JournalEntry.fromMap(json)).toList();
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore.collection('users').doc(user.uid).collection('plants').doc(plantId)
            .collection('journal_entries').orderBy('date', descending: true).get();
        if (snapshot.docs.isNotEmpty) {
          final cloudEntries = await Future.wait(snapshot.docs.map((doc) => JournalEntry.fromMapCloud(doc.data())));
          for (var entry in cloudEntries) {
            await db.insert('journal_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
          return cloudEntries.toList();
        }
      } catch (e) {
        debugPrint("Buluttan günlük kaydı getirme hatası: $e");
      }
    }
    return entries;
  }
  
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}