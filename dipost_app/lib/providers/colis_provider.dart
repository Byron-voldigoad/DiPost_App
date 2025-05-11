import 'package:flutter/material.dart';
import '../models/colis.dart';
import '../services/database_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ColisProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Colis> _colisList = [];
  bool _isLoading = false;

  List<Colis> get colisList => _colisList;
  bool get isLoading => _isLoading;

  Future<void> loadColis({required int? userId, required String? userRole}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> result = [];

      if (userRole == 'client') {
        result = await db.query(
          'colis',
          where: 'id_destinataire = ?',
          whereArgs: [userId],
        );
      } 
      else if (userRole == 'livreur') {
        result = await db.query(
          'colis',
          where: 'statut = ? OR statut = ?',
          whereArgs: ['En transit', 'Assigné'],
        );
      }
      else if (userRole == 'admin' || userRole == 'operateur') {
        result = await db.query('colis');
      }

      _colisList = result.map((map) => Colis.fromMap(map)).toList();
      debugPrint('Nombre de colis récupérés: ${_colisList.length}');
    } catch (e) {
      debugPrint('Erreur lors du chargement des colis: $e');
      _colisList = []; // Réinitialiser la liste en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Colis>> getUserColis(int userId) async {
  final db = await _dbHelper.database;
  final result = await db.rawQuery('''
    SELECT 
      c.id_colis, c.id_ibox, c.contenu, c.statut, c.created_at, c.updated_at,
      c.id_destinataire, c.id_expediteur,
      dest.nom as destinataire_nom, dest.prenom as destinataire_prenom,
      exp.nom as expediteur_nom, exp.prenom as expediteur_prenom
    FROM colis c
    LEFT JOIN utilisateurs dest ON c.id_destinataire = dest.id_utilisateur
    LEFT JOIN utilisateurs exp ON c.id_expediteur = exp.id_utilisateur
    WHERE c.id_destinataire = ? OR c.id_expediteur = ?
  ''', [userId, userId]);
  
  return result.map((map) => Colis.fromMap(map)).toList();
}

Future<Colis?> getColisWithDetails(int colisId) async {
  final db = await _dbHelper.database;
  final result = await db.rawQuery('''
    SELECT 
      c.id_colis, c.id_ibox, c.contenu, c.statut, c.created_at, c.updated_at,
      c.id_destinataire, c.id_expediteur,
      dest.nom as destinataire_nom, dest.prenom as destinataire_prenom,
      exp.nom as expediteur_nom, exp.prenom as expediteur_prenom,
      ibox.adresse as ibox_adresse
    FROM colis c
    LEFT JOIN utilisateurs dest ON c.id_destinataire = dest.id_utilisateur
    LEFT JOIN utilisateurs exp ON c.id_expediteur = exp.id_utilisateur
    LEFT JOIN ibox ON c.id_ibox = ibox.id_ibox
    WHERE c.id_colis = ?
  ''', [colisId]);

  if (result.isNotEmpty) {
    return Colis.fromMap(result.first);
  }
  return null;
}

Colis? getColisById(int id) {
  try {
    final colis = _colisList.firstWhere((colis) => colis.id == id);
    return colis;
  } catch (e) {
    return null;
  }
}

Future<void> updateColis(Colis colis) async {
  try {
    final db = await _dbHelper.database;
    
    // Mise à jour de tous les champs nécessaires
    await db.update(
      'colis',
      {
        'contenu': colis.contenu,
        'statut': colis.statut,
        'id_ibox': colis.iboxId,
        'id_destinataire': colis.destinataireId,
        'id_expediteur': colis.expediteurId,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id_colis = ?',
      whereArgs: [colis.id],
    );

    // Mettre à jour la liste locale
    final index = _colisList.indexWhere((c) => c.id == colis.id);
    if (index != -1) {
      _colisList[index] = colis;
      notifyListeners();
    }

    // Recharger les détails
    final updatedColis = await getColisWithDetails(colis.id);
    if (updatedColis != null && index != -1) {
      _colisList[index] = updatedColis;
      notifyListeners();
    }

  } catch (e) {
    debugPrint('Erreur lors de la mise à jour du colis: $e');
    throw Exception('Erreur lors de la mise à jour du colis: ${e.toString()}');
  }
}

Future<void> createColis(Colis colis) async {
  try {
    final db = await _dbHelper.database;
    
    // Récupérer les infos du destinataire
    final destinataire = await db.query(
      'utilisateurs',
      where: 'id_utilisateur = ?',
      whereArgs: [colis.destinataireId],
      limit: 1,
    );

    if (destinataire.isEmpty) {
      throw Exception('Destinataire non trouvé');
    }

    // Préparer les données pour l'insertion
    final colisData = {
      'contenu': colis.contenu,
      'statut': colis.statut,
      'id_ibox': colis.iboxId, // peut être null
      'id_destinataire': colis.destinataireId,
      'id_expediteur': colis.expediteurId,
      'created_at': colis.createdAt?.toIso8601String(),
      'updated_at': colis.updatedAt?.toIso8601String(),
    };

    // Insérer dans la base
    final id = await db.insert('colis', colisData);

    // Créer l'objet Colis complet avec l'ID généré
    final newColis = colis.copyWith(
      id: id,
      destinataireNom: destinataire.first['nom'] as String,
      destinatairePrenom: destinataire.first['prenom'] as String,
    );

    // Mettre à jour la liste locale
    _colisList.add(newColis);
    notifyListeners();

    debugPrint('Colis créé avec ID: $id');
  } catch (e) {
    debugPrint('Erreur création colis: $e');
    throw Exception('Erreur lors de la création du colis: ${e.toString()}');
  }
}

}