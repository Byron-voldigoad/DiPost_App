import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import '../dao/user_dao.dart';
import '../database/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  AppState _state = AppState();
  AppState get state => _state;

  final AuthService _authService;

  AuthProvider() : _authService = AuthService(UserDao(DatabaseHelper.instance));

  Future<void> register(String email, String phone, String password) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final success = await _authService.register(email, phone, password);
      if (success) {
        _state = _state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          postalId: email, // Pour le moment, on utilise l'email comme identifiant
        );
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Échec de l\'enregistrement',
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _state = _state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          postalId: user.email,
          error: null,
        );
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Email ou mot de passe incorrect',
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  void logout() {
    _state = AppState();
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}