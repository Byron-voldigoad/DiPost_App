// models/signature.dart
class MySignature {
  final int? id;
  final int userId;
  final String documentPath;
  final String documentType;
  final String signatureData;
  final DateTime createdAt;

  MySignature({
    this.id,
    required this.userId,
    required this.documentPath,
    required this.documentType,
    required this.signatureData,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_utilisateur': userId,
      'document_path': documentPath,
      'document_type': documentType,
      'signature_data': signatureData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MySignature.fromMap(Map<String, dynamic> map) {
    return MySignature(
      id: map['id'],
      userId: map['id_utilisateur'],
      documentPath: map['document_path'],
      documentType: map['document_type'],
      signatureData: map['signature_data'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}