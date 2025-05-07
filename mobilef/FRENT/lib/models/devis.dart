class Devis {
  final String? id;
  final String reference;
  final String clientId;
  final DateTime dateCreation;
  final DateTime dateValidite;
  final String adresseLivraison;
  final String conditionsPaiement;
  final double remise;
  final double sousTotalHT;
  final double totalTVA;
  final double totalHT;
  final double totalTTC;
  final List<DevisArticle> articles;
  final String methode;
  final String? imageDevis;
  final String statut;
  final String? createdBy;

  Devis({
    this.id,
    required this.reference,
    required this.clientId,
    required this.dateCreation,
    required this.dateValidite,
    required this.adresseLivraison,
    required this.conditionsPaiement,
    required this.remise,
    required this.sousTotalHT,
    required this.totalTVA,
    required this.totalHT,
    required this.totalTTC,
    required this.articles,
    required this.methode,
    this.imageDevis,
    required this.statut,
    this.createdBy, required String client, required DateTime date, required double total, required String validite, required String imagePath,
  });

  factory Devis.fromJson(Map<String, dynamic> json) {
    return Devis(
      id: json['_id'],
      reference: json['reference'],
      clientId: json['client'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateValidite: DateTime.parse(json['dateValidite']),
      adresseLivraison: json['adresseLivraison'],
      conditionsPaiement: json['conditionsPaiement'],
      remise: json['remise'].toDouble(),
      sousTotalHT: json['sousTotalHT'].toDouble(),
      totalTVA: json['totalTVA'].toDouble(),
      totalHT: json['totalHT'].toDouble(),
      totalTTC: json['totalTTC'].toDouble(),
      articles: List<DevisArticle>.from(
          json['articles'].map((x) => DevisArticle.fromJson(x))),
      methode: json['methode'],
      imageDevis: json['imageDevis'],
      statut: json['statut'],
      createdBy: json['createdBy'], 
      client: json['clients'],
      date: json['date'], 
      total: json['total'],
       validite: json['validite'],
        imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'client': clientId,
      'dateValidite': dateValidite.toIso8601String(),
      'adresseLivraison': adresseLivraison,
      'conditionsPaiement': conditionsPaiement,
      'remise': remise,
      'articles': articles.map((article) => article.toJson()).toList(),
      'methode': methode,
      'statut': statut,
    };
  }
}

class DevisArticle {
  final String articleId;
  final String nom;
  final String? description;
  final int quantite;
  final double prixHT;
  final double tva;
  final double montantHT;
  final double montantTVA;
  final double montantTTC;

  DevisArticle({
    required this.articleId,
    required this.nom,
    this.description,
    required this.quantite,
    required this.prixHT,
    required this.tva,
    required this.montantHT,
    required this.montantTVA,
    required this.montantTTC,
  });

  factory DevisArticle.fromJson(Map<String, dynamic> json) {
    return DevisArticle(
      articleId: json['article'],
      nom: json['nom'],
      description: json['description'],
      quantite: json['quantite'],
      prixHT: json['prixHT'].toDouble(),
      tva: json['tva'].toDouble(),
      montantHT: json['montantHT'].toDouble(),
      montantTVA: json['montantTVA'].toDouble(),
      montantTTC: json['montantTTC'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': articleId,
      'quantite': quantite,
      'description': description,
      'prixHT': prixHT,
      'tva': tva,
    };
  }
}