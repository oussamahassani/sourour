// Modèle de base pour les factures
abstract class Facture {
  final String id;
  final String numeroFacture;
  final String? produit;
  final int prixHT;
  final int tva;
  final int prixTTC;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateEcheance;
  final String createur;
  Object? client;
  Facture({
    required this.id,
    required this.numeroFacture,
    this.produit,
    required this.prixHT,
    required this.tva,
    required this.prixTTC,
    required this.statut,
    required this.dateCreation,
    required this.dateEcheance,
    required this.createur,
    this.client,
  });

  String get typeFacture;
}

// Modèle pour les factures de vente
class FactureVente extends Facture {
  final String? client;

  FactureVente({
    required String id,
    required String numeroFacture,
    required this.client,
    required produit,
    required int prixHT,
    required int tva,
    required int prixTTC,
    required String statut,
    required DateTime dateCreation,
    required DateTime dateEcheance,
    required String createur,
    String? type,
  }) : super(
         id: id,
         numeroFacture: numeroFacture,
         produit: produit,
         prixHT: prixHT,
         tva: tva,
         prixTTC: prixTTC,
         statut: statut,
         dateCreation: dateCreation,
         dateEcheance: dateEcheance,
         createur: createur,
       );

  @override
  String get typeFacture => 'Vente';

  // Pour créer une copie modifiée
  FactureVente copyWith({
    String? numeroFacture,
    String? client,
    String? produit,
    int? prixHT,
    int? tva,
    int? prixTTC,
    String? statut,
    DateTime? dateEcheance,
    String? createur,
    String? type,
  }) {
    return FactureVente(
      id: this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      client: client ?? this.client,
      produit: produit ?? this.produit,
      prixHT: prixHT ?? this.prixHT,
      tva: tva ?? this.tva,
      prixTTC: prixTTC ?? this.prixTTC,
      statut: statut ?? this.statut,
      dateCreation: this.dateCreation,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      createur: createur ?? this.createur,
    );
  }

  factory FactureVente.fromJson(Map<String, dynamic> json) {
    return FactureVente(
      client: json['idCL'] != null ? json['idCL']['_id'] : null,
      id: json['_id'],
      numeroFacture: json['numero_facture'],
      prixHT: json['prixHTV'],
      tva: json['TVA'],
      prixTTC: json['prixTTC'],
      statut: json['statut'],
      produit: json['idP'] != null ? json['idP']['_id'] : null,
      createur: json['idU'] != null ? json['idU']['_id'] : null,
      dateEcheance: DateTime.parse(json['date_echeance']),
      dateCreation: DateTime.parse(json['date_creation']),
      type: "Vente",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // ← tu peux l’enlever ici si le backend le génère automatiquement
      'numero_facture': numeroFacture,
      'idF': null,
      'idCL': client,
      'idP': produit,
      'prixHTV': prixHT,
      'TVA': tva,
      'prixTTC': prixTTC,
      'statut': statut,
      'dateCreation': dateCreation.toIso8601String(),
      'date_echeance': dateEcheance.toIso8601String(),
      'idU': createur,
      'type': "Vente",
    };
  }
}

// Modèle pour les factures d'achat
class FactureAchat extends Facture {
  final String? fournisseur;
  String? type;

  FactureAchat({
    required String id,
    required String numeroFacture,
    required this.fournisseur,
    required String produit,
    required int prixHT,
    required int tva,
    required int prixTTC,
    required String statut,
    required DateTime dateCreation,
    required DateTime dateEcheance,
    required String createur,
  }) : super(
         id: id,
         numeroFacture: numeroFacture,
         produit: produit,
         prixHT: prixHT,
         tva: tva,
         prixTTC: prixTTC,
         statut: statut,
         dateCreation: dateCreation,
         dateEcheance: dateEcheance,
         createur: createur,
       );

  @override
  String get typeFacture => 'Achat';
  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // ← tu peux l’enlever ici si le backend le génère automatiquement
      'numero_facture': numeroFacture,
      'idF': fournisseur,
      'idP': produit,
      'prixHTV': prixHT,
      'TVA': tva,
      'prixTTC': prixTTC,
      'statut': statut,
      'dateCreation': dateCreation.toIso8601String(),
      'date_echeance': dateEcheance.toIso8601String(),
      'idU': createur,
      'type': "Achat",
    };
  }

  factory FactureAchat.fromJson(Map<String, dynamic> json) {
    return FactureAchat(
      id: json['_id'],
      numeroFacture: json['numero_facture'],
      fournisseur: json['idF'] != null ? json['idF']['_id'] : null,
      prixHT: json['prixHTV'],
      tva: json['TVA'],
      prixTTC: json['prixTTC'],
      statut: json['statut'],
      produit: json['idP'] != null ? json['idP']['_id'] : null,
      createur: json['idU'] != null ? json['idU']['_id'] : null,
      dateEcheance: DateTime.parse(json['date_echeance']),
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  // Pour créer une copie modifiée
  FactureAchat copyWith({
    String? numeroFacture,
    String? fournisseur,
    String? produit,
    int? prixHT,
    int? tva,
    int? prixTTC,
    String? statut,
    DateTime? dateEcheance,
    String? createur,
  }) {
    return FactureAchat(
      id: this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      fournisseur: fournisseur ?? this.fournisseur,
      produit: produit ?? this.produit ?? "",
      prixHT: prixHT ?? this.prixHT,
      tva: tva ?? this.tva,
      prixTTC: prixTTC ?? this.prixTTC,
      statut: statut ?? this.statut,
      dateCreation: this.dateCreation,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      createur: createur ?? this.createur,
    );
  }
}
