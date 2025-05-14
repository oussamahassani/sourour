// Modèle de base pour les factures
abstract class Facture {
  final String id;
  final String numeroFacture;
  final String produit;
  final double prixHT;
  final double tva;
  final double prixTTC;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateEcheance;
  final String createur;

  Facture({
    required this.id,
    required this.numeroFacture,
    required this.produit,
    required this.prixHT,
    required this.tva,
    required this.prixTTC,
    required this.statut,
    required this.dateCreation,
    required this.dateEcheance,
    required this.createur,
  });

  String get typeFacture;
}

// Modèle pour les factures de vente
class FactureVente extends Facture {
  final String client;

  FactureVente({
    required String id,
    required String numeroFacture,
    required this.client,
    required String produit,
    required double prixHT,
    required double tva,
    required double prixTTC,
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
  String get typeFacture => 'Vente';

  // Pour créer une copie modifiée
  FactureVente copyWith({
    String? numeroFacture,
    String? client,
    String? produit,
    double? prixHT,
    double? tva,
    double? prixTTC,
    String? statut,
    DateTime? dateEcheance,
    String? createur,
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
}

// Modèle pour les factures d'achat
class FactureAchat extends Facture {
  final String fournisseur;

  FactureAchat({
    required String id,
    required String numeroFacture,
    required this.fournisseur,
    required String produit,
    required double prixHT,
    required double tva,
    required double prixTTC,
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

  // Pour créer une copie modifiée
  FactureAchat copyWith({
    String? numeroFacture,
    String? fournisseur,
    String? produit,
    double? prixHT,
    double? tva,
    double? prixTTC,
    String? statut,
    DateTime? dateEcheance,
    String? createur,
  }) {
    return FactureAchat(
      id: this.id,
      numeroFacture: numeroFacture ?? this.numeroFacture,
      fournisseur: fournisseur ?? this.fournisseur,
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
}
