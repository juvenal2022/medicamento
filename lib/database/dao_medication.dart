import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import '/models/medication_model.dart';

class DaoMedication {
  static Future<void> createTables(sql.Database db) async {
    await db.execute("""
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        schedule TEXT,
        is_taken BOOLEAN,
        taken_at TEXT
      );
    """);
  }

  static Future<sql.Database> openBank() async {
    final bank = await sql.openDatabase(
      'listmedications.db',
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
      },
      onOpen: (db) async {
        debugPrint('Banco aberto com sucesso!');
      }
    );
    return bank;
  }

  static Future<int> addMedication(MedicationModel med) async {
    final bank = await DaoMedication.openBank();
    final values = {
      'name': med.name,
      'dosage': med.dosage,
      'schedule': med.schedule,
      'is_taken': med.is_taken ? 1 : 0,
      'taken_at': med.taken_at
    };
    final idMedAdded = await bank.insert('medications', values);
    return idMedAdded;
  }

  static Future<List<MedicationModel>> getMedications() async {
    final bank = await DaoMedication.openBank();
    final maps = await bank.query('medications', orderBy: 'name');

    return maps.map((map) => MedicationModel.fromMap(map)).toList();
  }

  static Future<int> updateMedication(MedicationModel med) async {
    final bank = await DaoMedication.openBank();
    final values = {
      'name': med.name,
      'dosage': med.dosage,
      'schedule': med.schedule,
      'is_taken': med.is_taken ? 1 : 0,
      'taken_at': med.taken_at
    };
    final result = await bank.update('medications', values, where: 'id = ?', whereArgs: [med.id]);
  
    return result;
  }

  static Future<int> updateTakenStatus({
    required int id,
    required bool is_taken,
    String? taken_at,
  }) async {
    final bank = await DaoMedication.openBank();
    return bank.update(
      'medications',
      {
        'is_taken': is_taken ? 1 : 0,
        'taken_at': taken_at
      },
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  static Future<bool> removeMedication(MedicationModel med) async {
    final bank = await DaoMedication.openBank();
    try {
      await bank.delete('medications', where: 'id = ?', whereArgs: [med.id]);
      return true;
    } catch (error) {
      debugPrint('Falha na exclusão: $error');
      return false;
    }
  }

  static Future<bool> existsMedication({
    required String name,
    required String dosage,
    String? schedule,
  }) async {
    final db = await DaoMedication.openBank();
    final normalizedName = name.trim().toLowerCase();
    final normalizedDosage = dosage.trim().toLowerCase();
    final normalizedSchedule = (schedule ?? '').trim().toLowerCase();

    final rows = await db.query(
      'medications',
      columns: ['id', 'schedule'],
      where: 'LOWER(TRIM(name)) = ? AND LOWER(TRIM(dosage)) = ?',
      whereArgs: [normalizedName, normalizedDosage],
    );

    for (final row in rows) {
      final rowSchedule = ((row['schedule'] as String?) ?? '').trim().toLowerCase();
      if (normalizedSchedule.isEmpty || rowSchedule.isEmpty) {
        return true;
      }
      if (rowSchedule == normalizedSchedule) {
        return true;
      }
    }

    return false;
  }
}