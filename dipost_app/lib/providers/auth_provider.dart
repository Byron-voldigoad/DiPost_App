import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Permissions
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isOperateur => _user?.isOperateur ?? false;
  bool get isLivreur => _user?.isLivreur ?? false;
  bool get isClient => _user?.isClient ?? false;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );
      
      if (success) {
        return await login(email, password);
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  Future<bool> createUser({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String role,
  }) async {
    if (!isAdmin) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('utilisateurs', {
        'nom': nom,
        'prenom': prenom,
        'adresse_email': email,
        'telephone': telephone,
        'mot_de_passe': password,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('User creation error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}