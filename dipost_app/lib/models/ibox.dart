class IBox {
  final int id;
  final String adresse;
  final int capacite;
  final String statut; // Doit être parmi les valeurs prédéfinies
  final DateTime? createdAt;

  // Liste des statuts possibles
  static const List<String> statutsPossibles = [
    'Disponible',
    'Occupée',
    'En maintenance',
    'Hors service'
  ];

  IBox({
    required this.id,
    required this.adresse,
    required this.capacite,
    required this.statut,
    this.createdAt,
  }) : assert(statutsPossibles.contains(statut), 
           'Statut invalide. Doit être parmi: ${statutsPossibles.join(", ")}');

  factory IBox.fromMap(Map<String, dynamic> map) {
    return IBox(
      id: map['id_ibox'],
      adresse: map['adresse'],
      capacite: map['capacite'],
      statut: map['statut'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_ibox': id,
      'adresse': adresse,
      'capacite': capacite,
      'statut': statut,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}