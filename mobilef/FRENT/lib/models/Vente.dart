class Article {
  final String nom;
  final int quantite;
  final double prixHT;

  Article({required this.nom, required this.quantite, required this.prixHT});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      nom: json['nom'] ?? "",
      quantite: json['quantite'] ?? 1,
      prixHT: (json['prixHT'] as num).toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nom': nom, 'quantite': quantite, 'prixHT': prixHT};
  }
}

class VenteBonCommande {
  final String id;
  final String reference;
  final String client;
  final String date;
  final double total;
  final String statut;
  final List<Article> articles;
  final String adresse;
  final String conditions;
  final String delaiLivraison;
  final String remise;
  final String methode;

  VenteBonCommande({
    required this.reference,
    required this.id,
    required this.client,
    required this.date,
    required this.total,
    required this.statut,
    required this.articles,
    required this.adresse,
    required this.conditions,
    required this.delaiLivraison,
    required this.remise,
    required this.methode,
  });

  factory VenteBonCommande.fromJson(Map<String, dynamic> json) {
    return VenteBonCommande(
      id: json['_id'] ?? "",
      reference: json['reference'] ?? "",
      client: json['client'] as String,
      date: json['date'] as String,
      total: (json['total'] as num).toDouble(),
      statut: json['statut'] ?? "",
      adresse: json['adresse'] ?? "",
      conditions: json['conditions'] ?? "",
      delaiLivraison: json['delaiLivraison'] ?? "",
      remise: json['remise'] ?? "",
      methode: json['methode'] ?? "",
      articles:
          (json['articles'] as List<dynamic>)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }
  factory VenteBonCommande.fromJsonApidelete(Map<String, dynamic> json) {
    return VenteBonCommande(
      id: json['id'] ?? "",
      reference: json['reference'] ?? "",
      client: json['client'] != null ? json['client'] : "",
      date: json['date'] ?? "",
      total: (json['total'] as num).toDouble() ?? 0.0,
      statut: json['statut'] ?? "en Attente",
      adresse: json['adresse'] ?? "Adresse",
      conditions: json['conditions'] ?? "",
      delaiLivraison:
          json['delaiLivraison'] != null
              ? json['delaiLivraison'].toString()
              : "20",
      remise: json['methode'] != null ? json['remise'].toString() : "0",
      methode: "complete",
      articles: [],
    );
  }

  factory VenteBonCommande.fromJsonApi(Map<String, dynamic> json) {
    return VenteBonCommande(
      id: json['_id'] ?? "",
      reference: json['reference'] ?? "",
      client:
          json['client'] != null
              ? json['client']['nom'] + " " + json['client']['prenom']
              : "",
      date: json['dateCreation'] ?? "",
      total: (json['totalTTC'] as num).toDouble() ?? 0.0,
      statut: json['statut'] ?? "en Attente",
      adresse: json['adresseLivraison'] ?? "Adresse",
      conditions: json['conditionsPaiement'] ?? "",
      delaiLivraison:
          json['delaiLivraison'] != null
              ? json['delaiLivraison'].toString()
              : "20",
      remise: json['remise'] != null ? json['remise'].toString() : "0",
      methode: json['methode'] ?? "complete",
      articles:
          (json['articles'] as List<dynamic>)
              .map((item) => Article.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'client': client,
      'date': date,
      'total': total,
      'statut': statut,
      'articles': articles.map((article) => article.toJson()).toList(),
      'adresse': adresse,
      'conditions': conditions,
      'delaiLivraison': delaiLivraison,
      'remise': remise,
      'methode': methode,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': id,
      'reference': reference,
      'client': client,
      'date': date,
      'total': total,
      'statut': statut,
      'articles': articles.map((article) => article.toJson()).toList(),
      'adresse': adresse,
      'conditions': conditions,
      'delaiLivraison': delaiLivraison,
      'remise': remise,
      'methode': methode,
    };
  }

  Map<String, dynamic> toJsonVente() {
    return {
      'reference': reference ?? "",
      'client': client ?? "",
      'date': date ?? "",
      'total': total ?? "",
      'statut': statut ?? "",
      'articles': articles.map((article) => article.toJson()).toList(),
      'adresse': adresse ?? "",
      'conditions': conditions ?? "",
      'delaiLivraison': delaiLivraison ?? "",
      'remise': remise ?? "",
      'methode': methode ?? "",
    };
  }
}
