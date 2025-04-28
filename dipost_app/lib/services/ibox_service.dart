// IBox service 
import '../models/ibox.dart';
import '../services/database_helper.dart';

class IBoxService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<IBox>> getAllIBoxes() async {
    final db = await _dbHelper.database;
    final result = await db.query('ibox');
    return result.map((map) => IBox.fromMap(map)).toList();
  }

  Future<List<IBox>> getIBoxesByStatut(String statut) async {
    if (!IBox.statutsPossibles.contains(statut)) {
      throw ArgumentError('Statut invalide');
    }

    final db = await _dbHelper.database;
    final result = await db.query(
      'ibox',
      where: 'statut = ?',
      whereArgs: [statut],
    );
    return result.map((map) => IBox.fromMap(map)).toList();
  }

  Future<int> createIBox(IBox ibox) async {
    final db = await _dbHelper.database;
    return await db.insert('ibox', ibox.toMap());
  }

  Future<int> updateIBoxStatut(int id, String newStatut) async {
    if (!IBox.statutsPossibles.contains(newStatut)) {
      throw ArgumentError('Statut invalide');
    }

    final db = await _dbHelper.database;
    return await db.update(
      'ibox',
      {'statut': newStatut},
      where: 'id_ibox = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIBox(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'ibox',
      where: 'id_ibox = ?',
      whereArgs: [id],
    );
  }

  Future<IBox?> getIBoxById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'ibox',
      where: 'id_ibox = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? IBox.fromMap(result.first) : null;
  }
}