// models/colis.dart
class Colis {
  final int id;
  final int? iboxId;
  final int destinataireId;
  final int expediteurId;
  final String iboxAdresse;
  final String destinataireNom;
  final String destinatairePrenom;
  final String expediteurNom;
  final String expediteurPrenom;
  final String contenu;
  final String statut;
  final double? poids;
  final String? dimensions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Colis({
    required this.id,
    required this.iboxId,
    required this.destinataireId,
    required this.expediteurId,
    required this.iboxAdresse,
    required this.destinataireNom,
    required this.destinatairePrenom,
    required this.expediteurNom,
    required this.expediteurPrenom,
    required this.contenu,
    required this.statut,
    this.poids,
    this.dimensions,
    this.createdAt,
    this.updatedAt,
  });

  Colis copyWith({
    int? id,
    int? iboxId,
    int? destinataireId,
    int? expediteurId,
    String? iboxAdresse,
    String? destinataireNom,
    String? destinatairePrenom,
    String? expediteurNom,
    String? expediteurPrenom,
    String? contenu,
    String? statut,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Colis(
      id: id ?? this.id,
      iboxId: iboxId ?? this.iboxId,
      destinataireId: destinataireId ?? this.destinataireId,
      expediteurId: expediteurId ?? this.expediteurId,
      iboxAdresse: iboxAdresse ?? this.iboxAdresse,
      destinataireNom: destinataireNom ?? this.destinataireNom,
      destinatairePrenom: destinatairePrenom ?? this.destinatairePrenom,
      expediteurNom: expediteurNom ?? this.expediteurNom,
      expediteurPrenom: expediteurPrenom ?? this.expediteurPrenom,
      contenu: contenu ?? this.contenu,
      statut: statut ?? this.statut,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Colis.fromMap(Map<String, dynamic> map) {
  return Colis(
    id: map['id_colis'] as int,
    iboxId: map['id_ibox'] as int?,
    destinataireId: map['id_destinataire'] as int,
    expediteurId: map['id_expediteur'] as int,
    iboxAdresse: map['ibox_adresse']?.toString() ?? 'Non spécifié',
    destinataireNom: map['destinataire_nom']?.toString() ?? 'Non spécifié',
    destinatairePrenom: map['destinataire_prenom']?.toString() ?? 'Non spécifié',
    expediteurNom: map['expediteur_nom']?.toString() ?? 'Non spécifié',
    expediteurPrenom: map['expediteur_prenom']?.toString() ?? 'Non spécifié',
    contenu: map['contenu'] as String,
    statut: map['statut'] as String,
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id_colis': id,
      'id_ibox': iboxId,
      'id_destinataire': destinataireId,
      'id_expediteur': expediteurId,
      'ibox_adresse': iboxAdresse,
      'destinataire_nom': destinataireNom,
      'destinataire_prenom': destinatairePrenom,
      'expediteur_nom': expediteurNom,
      'expediteur_prenom': expediteurPrenom,
      'contenu': contenu,
      'statut': statut,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}