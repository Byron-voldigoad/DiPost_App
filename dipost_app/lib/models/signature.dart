// Signature model 
class Signature {
  final int id;
  final int userId;
  final String documentPath;
  final String niveau; // 'simple', 'avancee', 'qualifiee'
  final DateTime horodatage;
  final String? certificat;
  final String? qrCode;

  Signature({
    required this.id,
    required this.userId,
    required this.documentPath,
    required this.niveau,
    required this.horodatage,
    this.certificat,
    this.qrCode,
  });

  factory Signature.fromMap(Map<String, dynamic> map) {
    return Signature(
      id: map['id_signature'],
      userId: map['id_utilisateur'],
      documentPath: map['document'],
      niveau: map['niveau_signature'],
      horodatage: DateTime.parse(map['horodatage']),
      certificat: map['certificat'],
      qrCode: map['qr_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_signature': id,
      'id_utilisateur': userId,
      'document': documentPath,
      'niveau_signature': niveau,
      'horodatage': horodatage.toIso8601String(),
      'certificat': certificat,
      'qr_code': qrCode,
    };
  }
}