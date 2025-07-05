// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  // Singleton boilerplate
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;

  late final Database _db;

  Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'symptomtracker.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE logs(
            id INTEGER PRIMARY KEY,
            date INTEGER UNIQUE,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE meds(
            id INTEGER PRIMARY KEY,
            name TEXT,
            dosage TEXT,
            timesPerDay INTEGER,
            takenToday INTEGER
          )
        ''');
      },
    );
  }

  Database get db => _db;
}
