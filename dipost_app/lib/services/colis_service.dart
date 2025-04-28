import 'package:flutter/material.dart';
import '../models/colis.dart';
import './database_helper.dart';

class ColisService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Colis>> getUserColis(int userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'colis',
        where: 'id_destinataire = ?',
        whereArgs: [userId],
      );
      return result.map((map) => Colis.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting user colis: $e');
      return [];
    }
  }

  Future<List<Colis>> getColisForLivreur() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'colis',
        where: 'statut = ? OR statut = ?',
        whereArgs: ['En transit', 'Assigné'],
      );
      return result.map((map) => Colis.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting livreur colis: $e');
      return [];
    }
  }

  Future<List<Colis>> getAllColis() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('colis');
      return result.map((map) => Colis.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting all colis: $e');
      return [];
    }
  }
}