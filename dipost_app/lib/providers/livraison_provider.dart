// Livraison provider 
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../models/livraison.dart';

class LivraisonProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Livraison> _livraisons = [];

  List<Livraison> get livraisons => _livraisons;
  List<Livraison> _userLivraisons = [];

List<Livraison> get userLivraisons => _userLivraisons;

  Future<void> loadLivraisons() async {
  try {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT l.*, u.prenom as livreur_prenom, u.nom as livreur_nom 
      FROM livraisons l
      LEFT JOIN utilisateurs u ON l.livreur_id = u.id_utilisateur
      ORDER BY l.date_demande DESC
    ''');
    
    debugPrint('Résultats bruts: $result');
    
    _livraisons = result.map((map) {
      debugPrint('Mapping livraison: $map');
      return Livraison.fromMap(map);
    }).toList();
    
    notifyListeners();
  } catch (e) {
    debugPrint('Erreur loadLivraisons: $e');
  }
}

  Future<int> createLivraison(Livraison livraison) async {
  try {
    final db = await _dbHelper.database;
    
    debugPrint('Tentative d\'insertion: ${livraison.toMap()}'); // Log des données

    final id = await db.insert(
      'livraisons',
      livraison.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    debugPrint('Insertion réussie avec ID: $id');
    await loadLivraisons();
    
    return id;
  } catch (e, stackTrace) {
    debugPrint('ERREUR DÉTAILLÉE - createLivraison:');
    debugPrint('Type: ${e.runtimeType}');
    debugPrint('Message: ${e.toString()}');
    debugPrint('Stack trace: $stackTrace');
    throw Exception('Erreur technique lors de la création. Détails: ${e.toString()}');
  }
}


  Future<void> updateLivraison(Livraison livraison) async {
    final db = await _dbHelper.database;
    await db.update(
      'livraisons',
      livraison.toMap(),
      where: 'id_livraison = ?',
      whereArgs: [livraison.id],
    );
    await loadLivraisons();
  }

  Future<void> assignerLivreur(int livraisonId, int livreurId) async {
  try {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE livraisons 
      SET livreur_id = ?, statut = 'En cours', date_modification = ?
      WHERE id = ?
    ''', [livreurId, DateTime.now().toIso8601String(), livraisonId]);
    
    debugPrint('Assignation réussie: Livreur $livreurId -> Livraison $livraisonId');
    await loadLivraisons();
  } catch (e) {
    debugPrint('Erreur assignerLivreur: $e');
    throw Exception('Échec de l\'assignation: ${e.toString()}');
  }
}

  Future<Livraison?> getLivraisonByColisId(int colisId) async {
  try {
    final db = await _dbHelper.database;
    final result = await db.query(
      'livraisons',
      where: 'colis_id = ?',
      whereArgs: [colisId],
    );

    if (result.isNotEmpty) {
      // Vérification supplémentaire des données
      final map = result.first;
      if (map['statut'] == null) {
        map['statut'] = 'En attente';
      }
      if (map['date_demande'] == null) {
        map['date_demande'] = DateTime.now().toIso8601String();
      }
      return Livraison.fromMap(map);
    }
    return null;
  } catch (e) {
    debugPrint('Erreur lors de la récupération de la livraison: $e');
    throw Exception('Erreur lors de la récupération de la livraison: ${e.toString()}');
  }
}


Future<List<Livraison>> getLivraisonsByUserId(int userId) async {
  try {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT l.* FROM livraisons l
      JOIN colis c ON l.colis_id = c.id_colis
      WHERE c.id_destinataire = ?
      OR c.id_expediteur = ?
      ORDER BY l.date_demande DESC
    ''', [userId,userId]);

    return result.map((map) => Livraison.fromMap(map)).toList();
  } catch (e) {
    debugPrint('Erreur lors de la récupération des livraisons: $e');
    throw Exception('Erreur lors de la récupération des livraisons');
  }
}

Future<Livraison?> getLivraisonById(int id) async {
  try {
    final db = await _dbHelper.database;
    final result = await db.query(
      'livraisons',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Livraison.fromMap(result.first);
    }
    return null;
  } catch (e) {
    debugPrint('Erreur lors de la récupération de la livraison: $e');
    throw Exception('Erreur lors de la récupération de la livraison');
  }
}

Future<void> loadLivraisonsByUser(int userId) async {
  try {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT l.* FROM livraisons l
      JOIN colis c ON l.colis_id = c.id_colis
      WHERE c.id_destinataire = ?
      OR c.id_expediteur = ?
      ORDER BY l.date_demande DESC
    ''', [userId,userId]);
    
    _userLivraisons = result.map((map) => Livraison.fromMap(map)).toList();
    notifyListeners();
  } catch (e) {
    debugPrint('Erreur chargement livraisons utilisateur: $e');
    throw Exception('Erreur chargement livraisons');
  }
}

}