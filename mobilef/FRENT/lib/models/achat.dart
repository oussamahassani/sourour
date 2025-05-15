class Purchase {
  final String? id;
  final String id_article;
  final String id_fournisseur;
  final double prix_achatHT;
  final double TVA;
  final int quantite;
  final double prix_achatTTC;
  final int? delai_livraison;
  final String type_achat;
  final DateTime date_achat;

  Purchase({
    this.id,
    required this.id_article,
    required this.id_fournisseur,
    required this.prix_achatHT,
    required this.TVA,
    required this.quantite,
    required this.prix_achatTTC,
    this.delai_livraison,
    required this.type_achat,
    required this.date_achat,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'id_article': id_article,
        'id_fournisseur': id_fournisseur,
        'prix_achatHT': prix_achatHT,
        'TVA': TVA,
        'quantite': quantite,
        'prix_achatTTC': prix_achatTTC,
        'delai_livraison': delai_livraison,
        'type_achat': type_achat,
        'date_achat': date_achat.toIso8601String(),
      };

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['_id']?.toString(),
        id_article: json['id_article'].toString(),
        id_fournisseur: json['id_fournisseur'].toString(),
        prix_achatHT: double.parse(json['prix_achatHT'].toString()),
        TVA: double.parse(json['TVA'].toString()),
        quantite: int.parse(json['quantite'].toString()),
        prix_achatTTC: double.parse(json['prix_achatTTC'].toString()),
        delai_livraison: json['delai_livraison'] != null ? int.parse(json['delai_livraison'].toString()) : null,
        type_achat: json['type_achat'].toString(),
        date_achat: DateTime.parse(json['date_achat']),
      );

  static double calculateTTC(double prixHT, double tva, int quantite) {
    return prixHT * quantite * (1 + tva / 100);
  }
}
