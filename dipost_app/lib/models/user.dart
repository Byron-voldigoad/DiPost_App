class User {
  final int? id;
  final String email;
  final String phone;
  final String passwordHash;
  final String createdAt;
  final String updatedAt;

  User({
    this.id,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
  return User(
    id: map['id'],
    email: map['email'],
    phone: map['phone'],
    passwordHash: map['passwordHash'],
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}
}