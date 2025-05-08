import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> loadUsers({String? role}) async {
    final db = await _dbHelper.database;
    final where = role != null ? 'role = ?' : null;
    final whereArgs = role != null ? [role] : null;
    
    final result = await db.query('utilisateurs', where: where, whereArgs: whereArgs);
    _users = result.map((map) => User.fromMap(map)).toList();
    notifyListeners();
  }

  Future<List<User>> getLivreurs() async {
    await loadUsers(role: 'livreur');
    return _users.where((u) => u.role == 'livreur').toList();
  }
}