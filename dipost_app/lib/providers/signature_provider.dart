// Signature provider 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/signature.dart';
import '../services/signature_service.dart';

class SignatureProvider with ChangeNotifier {
  final SignatureService _signatureService = SignatureService();
  List<Signature> _signatures = [];
  bool _isLoading = false;

  List<Signature> get signatures => _signatures;
  bool get isLoading => _isLoading;

  Future<void> loadUserSignatures(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _signatures = await _signatureService.getUserSignatures(userId);
    } catch (e) {
      debugPrint('Error loading signatures: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSignature({
    required XFile document,
    required String niveau,
  }) async {
    try {
      // Dans une vraie application, vous auriez le userId du user connecté
      await _signatureService.createSignature(
        userId: 1, // Remplacer par l'ID réel
        document: document,
        niveau: niveau,
      );
      await loadUserSignatures(1); // Recharger les signatures
      return true;
    } catch (e) {
      debugPrint('Error creating signature: $e');
      return false;
    }
  }
}