// Signature service 
import 'package:image_picker/image_picker.dart';
import '../models/signature.dart';
import '../services/database_helper.dart';

class SignatureService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  Future<List<Signature>> getUserSignatures(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'signatures',
      where: 'id_utilisateur = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Signature.fromMap(map)).toList();
  }

  Future<int> createSignature({
    required int userId,
    required XFile document,
    required String niveau,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert('signatures', {
      'id_utilisateur': userId,
      'document': document.path,
      'niveau_signature': niveau,
      'horodatage': DateTime.now().toIso8601String(),
      // Dans une vraie application, générer un certificat et QR code
      'certificat': 'cert_${DateTime.now().millisecondsSinceEpoch}',
      'qr_code': 'qr_${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  Future<bool> verifySignature(int signatureId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'signatures',
      where: 'id_signature = ?',
      whereArgs: [signatureId],
    );
    return result.isNotEmpty;
  }
}