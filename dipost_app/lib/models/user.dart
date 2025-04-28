class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    required this.role,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isOperateur => role == 'operateur';
  bool get isLivreur => role == 'livreur';
  bool get isClient => role == 'client';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id_utilisateur'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['adresse_email'],
      telephone: map['telephone'],
      role: map['role'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': id,
      'nom': nom,
      'prenom': prenom,
      'adresse_email': email,
      'telephone': telephone,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}