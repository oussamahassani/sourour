class Purchase {
  final String? id;
  final String articleId;
  final String supplierId;
  final double prixHT;
  final double tva;
  final int quantite;
  final double prixTTC;
  final int? delaiLivraison; // Optional, used only for OrderedPurchase

  Purchase({
    this.id,
    required this.articleId,
    required this.supplierId,
    required this.prixHT,
    required this.tva,
    required this.quantite,
    required this.prixTTC,
    this.delaiLivraison, required DateTime date,
  });

  // Calculate TTC price
  static double calculateTTC(double prixHT, double tva, int quantite) {
    return prixHT * (1 + tva / 100) * quantite;
  }

  // Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'articleId': articleId,
      'supplierId': supplierId,
      'prixHT': prixHT,
      'tva': tva,
      'quantite': quantite,
      'prixTTC': prixTTC,
      if (delaiLivraison != null) 'delaiLivraison': delaiLivraison,
    };
  }

  // Create from JSON
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      articleId: json['articleId'],
      supplierId: json['supplierId'],
      prixHT: json['prixHT'],
      tva: json['tva'],
      quantite: json['quantite'],
      prixTTC: json['prixTTC'],
      delaiLivraison: json['delaiLivraison'], date:  json['date'],
    );
  }

  DateTime get date => DateTime.now();
}
