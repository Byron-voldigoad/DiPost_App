import 'package:dipost_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ibox.dart';
import '../dao/ibox_dao.dart';
import '../database/database_helper.dart';

class IBoxProvider extends ChangeNotifier {
  List<IBox> _iboxes = [];
  bool _isLoading = false;
  String? _error;

  List<IBox> get iboxes => _iboxes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final IBoxDao _iboxDao;

  IBoxProvider() : _iboxDao = IBoxDao(DatabaseHelper.instance);

  Future<void> loadUserIBoxes(String postalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _iboxes = await _iboxDao.getUserIBoxes(postalId);
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addIBox(IBox newBox) async {
    try {
      await _iboxDao.createIBox(newBox);
      await loadUserIBoxes(newBox.senderId ?? '');
      return true;
    } catch (e) {
      _error = 'Erreur d\'ajout: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIBoxStatus(int id, String newStatus) async {
    try {
      final index = _iboxes.indexWhere((box) => box.id == id);
      if (index != -1) {
        final updatedBox = _iboxes[index].copyWith(status: newStatus);
        await _iboxDao.updateIBox(updatedBox);
        await loadUserIBoxes(updatedBox.senderId ?? '');
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur de mise à jour: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

 Future<bool> deleteIBox(int id, String postalId) async {
  try {
    await _iboxDao.deleteIBox(id);
    await loadUserIBoxes(postalId);
    return true;
  } catch (e) {
    _error = 'Erreur de suppression: ${e.toString()}';
    notifyListeners();
    return false;
  }
}

Future<void> updateParcelInIBox(int iboxId, String parcelId) async {
  try {
    _isLoading = true;
    notifyListeners();

    // Trouver l'iBox à mettre à jour
    final index = _iboxes.indexWhere((box) => box.id == iboxId);
    if (index != -1) {
      final updatedBox = _iboxes[index].copyWith(parcelId: parcelId);
      await _iboxDao.updateIBox(updatedBox);
      await loadUserIBoxes(updatedBox.senderId!);
    }
  } catch (e) {
    _error = 'Erreur lors de l\'ajout du colis: $e';
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  void clearError() {
    _error = null;
    notifyListeners();
  }
}