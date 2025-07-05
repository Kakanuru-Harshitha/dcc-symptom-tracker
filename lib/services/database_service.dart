// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;

  late final Database _db;

  Future<void> init() async {
    final dbPath = join(await getDatabasesPath(), 'symptomtracker.db');
    _db = await openDatabase(
      dbPath,
      version: 2, // bumped from 1 → 2
      onCreate: (db, version) async {
        // Initial creation for brand-new installs:
        await db.execute('''
          CREATE TABLE logs(
            id   INTEGER PRIMARY KEY,
            date INTEGER,
            data TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE meds(
            id            INTEGER PRIMARY KEY,
            name          TEXT,
            dosage        TEXT,
            timesPerDay   INTEGER,
            takenToday    INTEGER
          );
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // Migrate logs → logs_old
          await db.execute('ALTER TABLE logs RENAME TO logs_old;');
          // Recreate logs without UNIQUE constraint
          await db.execute('''
            CREATE TABLE logs(
              id   INTEGER PRIMARY KEY,
              date INTEGER,
              data TEXT
            );
          ''');
          // Copy over existing data
          await db.execute('''
            INSERT INTO logs(id, date, data)
            SELECT id, date, data FROM logs_old;
          ''');
          // Drop the old table
          await db.execute('DROP TABLE logs_old;');
        }
      },
    );
  }

  Database get db => _db;
}
