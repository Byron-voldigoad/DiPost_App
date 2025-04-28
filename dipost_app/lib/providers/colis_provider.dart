import 'package:flutter/material.dart';
import '../models/colis.dart';
import '../services/database_helper.dart';

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

}