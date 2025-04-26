import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class UserDao {
  final DatabaseHelper dbHelper;

  UserDao(this.dbHelper);

  Future<int> createUser(User user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<User?> getUserByPhone(String phone) async {
  final db = await dbHelper.database;
  final maps = await db.query(
    'users',
    where: 'phone = ?',
    whereArgs: [phone],
  );

  if (maps.isNotEmpty) {
    return User.fromMap(maps.first);
  }
  return null;
}

}