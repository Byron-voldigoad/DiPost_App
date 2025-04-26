import 'package:sqflite/sqflite.dart';
import '../models/ibox.dart';
import '../database/database_helper.dart';

class IBoxDao {
  final DatabaseHelper dbHelper;

  IBoxDao(this.dbHelper);

  Future<int> createIBox(IBox box) async {
    final db = await dbHelper.database;
    return await db.insert('iboxes', box.toMap());
  }

  Future<List<IBox>> getUserIBoxes(String postalId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'iboxes',
      where: 'senderId = ? OR parcelId LIKE ?',
      whereArgs: [postalId, '%$postalId%'],
    );

    return List.generate(maps.length, (i) => IBox.fromMap(maps[i]));
  }

  Future<int> updateIBox(IBox box) async {
    final db = await dbHelper.database;
    return await db.update(
      'iboxes',
      box.toMap(),
      where: 'id = ?',
      whereArgs: [box.id],
    );
  }

  Future<int> deleteIBox(int id) async {
  final db = await dbHelper.database;
  return await db.delete(
    'iboxes',
    where: 'id = ?',
    whereArgs: [id],
  );
}
}