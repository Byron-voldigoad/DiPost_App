class Document {
  final int? id;
  final int userId;
  final String filePath;
  final String type;
  final DateTime uploadDate;

  Document({
    this.id,
    required this.userId,
    required this.filePath,
    required this.type,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'file_path': filePath,
      'type': type,
      'upload_date': uploadDate.toIso8601String(),
    };
  }
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      userId: map['user_id'],
      filePath: map['file_path'],
      type: map['type'],
      uploadDate: DateTime.parse(map['upload_date']),
    );
  }
}