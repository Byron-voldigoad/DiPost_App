import 'package:flutter/material.dart';

import '../models/user.dart';
import './database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<User?> login(String email, String password) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'utilisateurs',
      where: 'adresse_email = ? AND mot_de_passe = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final db = await _dbHelper.database;
    try {
      // Vérifier si l'email existe déjà
      final existing = await db.query(
        'utilisateurs',
        where: 'adresse_email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        throw 'Un compte avec cet email existe déjà';
      }

      // Créer un nouveau client
      await db.insert('utilisateurs', {
        'nom': nom,
        'prenom': prenom,
        'adresse_email': email,
        'telephone': telephone,
        'mot_de_passe': password,
        'role': 'client', // Par défaut, un client
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }
}