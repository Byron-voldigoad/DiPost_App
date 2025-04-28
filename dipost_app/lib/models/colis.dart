// models/colis.dart
class Colis {
  final int id;
  final int? iboxId;
  final int destinataireId;
  final int expediteurId;
  final String iboxAdresse;
  final String destinataireNom; // Ajouté
  final String destinatairePrenom; // Ajouté
  final String expediteurNom; // Ajouté
  final String expediteurPrenom; // Ajouté
  final String contenu;
  final String statut;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Colis({
    required this.id,
    required this.iboxId,
    required this.destinataireId,
    required this.expediteurId,
    required this.iboxAdresse,
    required this.destinataireNom, // Ajouté
    required this.destinatairePrenom, // Ajouté
    required this.expediteurNom, // Ajouté
    required this.expediteurPrenom, // Ajouté
    required this.contenu,
    required this.statut,
    this.createdAt,
    this.updatedAt,
  });

  factory Colis.fromMap(Map<String, dynamic> map) {
  return Colis(
    id: map['id_colis'],
    iboxId: map['id_ibox'],
    destinataireId: map['id_destinataire'],
    expediteurId: map['id_expediteur'],
    iboxAdresse: map['ibox_adresse']?.toString() ?? 'Non spécifié',
    destinataireNom: map['destinataire_nom']?.toString() ?? 'Non spécifié',
    destinatairePrenom: map['destinataire_prenom']?.toString() ?? 'Non spécifié',
    expediteurNom: map['expediteur_nom']?.toString() ?? 'Non spécifié',
    expediteurPrenom: map['expediteur_prenom']?.toString() ?? 'Non spécifié',
    contenu: map['contenu'],
    statut: map['statut'],
    createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id_colis': id,
      'id_ibox': iboxId,
      'id_destinataire': destinataireId,
      'id_expediteur': expediteurId,
      'ibox_adresse': iboxAdresse,
      'destinataire_nom': destinataireNom, // Ajouté
      'destinataire_prenom': destinatairePrenom, // Ajouté
      'expediteur_nom': expediteurNom, // Ajouté
      'expediteur_prenom': expediteurPrenom, // Ajouté
      'contenu': contenu,
      'statut': statut,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}