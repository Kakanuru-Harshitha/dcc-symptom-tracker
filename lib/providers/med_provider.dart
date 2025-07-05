// lib/providers/med_provider.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medication.dart';
import '../services/database_service.dart';

class MedProvider extends ChangeNotifier {
  final Database _db = DatabaseService().db;
  List<Medication> meds = [];

  Future<void> load() async {
    final rows = await _db.query('meds');
    meds = rows.map((r) => Medication.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> addOrUpdate(Medication m) async {
    if (m.id == null) {
      m.id = await _db.insert('meds', m.toMap());
    } else {
      await _db.update('meds', m.toMap(),
          where: 'id=?', whereArgs: [m.id]);
    }
    await load();
  }

  Future<void> toggleTaken(Medication m) async {
    m.takenToday = !m.takenToday;
    await addOrUpdate(m);
  }
}
