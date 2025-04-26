import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../dao/user_dao.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService {
  final UserDao userDao;

  AuthService(this.userDao);

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> register(String email, String phone, String password) async {
  try {
    // Vérifier d'abord si l'utilisateur existe
    final existingUser = await userDao.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }

    // Vérifier si le numéro existe déjà
    final existingPhoneUser = await userDao.getUserByPhone(phone);
    if (existingPhoneUser != null) {
      throw Exception('Un utilisateur avec ce numéro existe déjà');
    }

    final passwordHash = _hashPassword(password);
    final user = User(
      email: email,
      phone: phone,
      passwordHash: passwordHash,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    final userId = await userDao.createUser(user);
    return userId > 0; // Retourne true si l'ID est valide
  } catch (e) {
    print('Erreur d\'enregistrement: ${e.toString()}');
    rethrow; // Renvoie l'erreur pour qu'elle soit capturée par le Provider
  }
}

  Future<User?> login(String email, String password) async {
    try {
      final user = await userDao.getUserByEmail(email);
      if (user == null) return null;

      final inputHash = _hashPassword(password);
      if (inputHash == user.passwordHash) {
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}