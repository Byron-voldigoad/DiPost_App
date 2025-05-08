class Livraison {
  final int id;
  final int colisId;
  final int livreurId;
  final String statut;
  final DateTime dateDemande;
  final DateTime? dateLivraison;

  Livraison({
    this.id = 0, // Valeur par défaut
    required this.colisId,
    this.livreurId = 0, // Valeur par défaut
    this.statut = 'En attente', // Valeur par défaut
    DateTime? dateDemande,
    this.dateLivraison,
  }) : dateDemande = dateDemande ?? DateTime.now();

  factory Livraison.fromMap(Map<String, dynamic> map) {
    return Livraison(
      id: map['id'] as int? ?? 0,
      colisId: map['colis_id'] as int? ?? 0,
      livreurId: map['livreur_id'] as int? ?? 0,
      statut: (map['statut'] ?? 'En attente') as String,
      dateDemande: map['date_demande'] != null 
          ? DateTime.tryParse(map['date_demande'].toString()) ?? DateTime.now()
          : null,
      dateLivraison: map['date_livraison'] != null 
          ? DateTime.tryParse(map['date_livraison'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'colis_id': colisId,
      'livreur_id': livreurId,
      'statut': statut,
      'date_demande': dateDemande.toIso8601String(),
      'date_livraison': dateLivraison?.toIso8601String(),
    };
  }
}