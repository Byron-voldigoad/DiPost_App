//ibox_provider.dart
import 'package:dipost_app/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../models/ibox.dart';
import '../services/ibox_service.dart';

class IBoxProvider with ChangeNotifier {
  final IBoxService _iboxService = IBoxService();
  List<IBox> _iboxes = [];
  bool _isLoading = false;
  String? _currentFilterStatut;

  List<IBox> get iboxes => _iboxes;
  bool get isLoading => _isLoading;
  String? get currentFilterStatut => _currentFilterStatut;

  Future<void> loadIBoxes({String? statut}) async {
    _isLoading = true;
    _currentFilterStatut = statut;
    notifyListeners();

    try {
      if (statut != null) {
        _iboxes = await _iboxService.getIBoxesByStatut(statut);
      } else {
        _iboxes = await _iboxService.getAllIBoxes();
      }
    } catch (e) {
      debugPrint('Error loading iBoxes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addIBox(IBox newIBox) async {
    try {
      final id = await _iboxService.createIBox(newIBox);
      await loadIBoxes(statut: _currentFilterStatut);
      return id;
    } catch (e) {
      debugPrint('Error adding iBox: $e');
      return -1;
    }
  }

  Future<bool> updateIBoxStatut(int id, String newStatut) async {
    try {
      await _iboxService.updateIBoxStatut(id, newStatut);
      await loadIBoxes(statut: _currentFilterStatut);
      return true;
    } catch (e) {
      debugPrint('Error updating iBox status: $e');
      return false;
    }
  }

  Future<IBox?> getIBoxById(int id) async {
  try {
    return await _iboxService.getIBoxById(id);
  } catch (e) {
    debugPrint('Error getting iBox by id: $e');
    return null;
  }
}

Future<List<IBox>> getOperatorsIBoxes(int operatorId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('''
      SELECT ibox.* FROM ibox
      JOIN user_ibox ON ibox.id_ibox = user_ibox.ibox_id
      WHERE user_ibox.user_id = ?
    ''', [operatorId]);

    return result.map((map) => IBox.fromMap(map)).toList();
  }

  Future<bool> updateIBoxStatus(int iboxId, String newStatus, {int? operatorId}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      if (operatorId != null) {
        // Vérifier que l'opérateur gère bien cette iBox
        final managed = await db.rawQuery('''
          SELECT 1 FROM user_ibox 
          WHERE user_id = ? AND ibox_id = ?
        ''', [operatorId, iboxId]);

        if (managed.isEmpty) return false;
      }

      await db.update(
        'ibox',
        {'statut': newStatus},
        where: 'id_ibox = ?',
        whereArgs: [iboxId],
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update iBox status error: $e');
      return false;
    }
  }

}