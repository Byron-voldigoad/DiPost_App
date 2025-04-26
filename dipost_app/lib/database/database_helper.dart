import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dipost.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(
    path,
    version: 1,
    onCreate: _createDB,
    onOpen: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    },
  );
}

 Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      phone TEXT UNIQUE NOT NULL,
      passwordHash TEXT NOT NULL,
      createdAt TEXT,
      updatedAt TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS iboxes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      boxId TEXT NOT NULL,
      location TEXT NOT NULL,
      size TEXT NOT NULL,
      reservationDate TEXT NOT NULL,
      collectionDate TEXT,
      status TEXT NOT NULL,
      parcelId TEXT,
      senderId TEXT
    )
  ''');
}
  // Nous ajouterons d'autres tables plus tard


  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<void> deleteAppDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dipost.db');
  await deleteDatabase(path);
  print('Base de données supprimée');
}
}