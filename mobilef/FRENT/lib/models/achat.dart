import 'article.dart';
import 'fournisseur.dart';

class AchatDirect {
  final String? id;
  final String reference;
  final DateTime date;
  final Fournisseur fournisseur;
  final String responsable;
  final String adresseLivraison;
  final double remise;
  final String delaiLivraison;
  final List<LigneAchat> articles;
  final String statut; // Non nullable avec valeur par défaut
  final String notes; // Non nullable avec valeur par défaut

  AchatDirect({
    this.id,
    required this.reference,
    required this.date,
    required this.fournisseur,
    required this.responsable,
    required this.adresseLivraison,
    this.remise = 0,
    required this.delaiLivraison,
    required this.articles,
    this.statut = 'En cours',
    this.notes = '', // Toujours initialisé avec chaîne vide
  });

  factory AchatDirect.fromJson(Map<String, dynamic> json) {
    return AchatDirect(
      id: json['_id'] as String?,
      reference: json['reference'] as String? ?? '', // Null-safe
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toString()),
      fournisseur: Fournisseur.fromJson(json['fournisseur'] as Map<String, dynamic>? ?? {}),
      responsable: json['responsable'] as String? ?? '',
      adresseLivraison: json['adresseLivraison'] as String? ?? '',
      remise: (json['remise'] as num?)?.toDouble() ?? 0,
      delaiLivraison: json['delaiLivraison'] as String? ?? '',
      articles: List<LigneAchat>.from(
        (json['articles'] as List?)?.map((x) => LigneAchat.fromJson(x as Map<String, dynamic>)) ?? [],
      ),
      statut: json['statut'] as String? ?? 'En cours',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'reference': reference,
      'date': date.toIso8601String(),
      'fournisseur': fournisseur.toJson(),
      'responsable': responsable,
      'adresseLivraison': adresseLivraison,
      'remise': remise,
      'delaiLivraison': delaiLivraison,
      'articles': articles.map((x) => x.toJson()).toList(),
      'statut': statut,
      'notes': notes,
    };
  }

  double get totalHT => articles.fold(0, (sum, article) => sum + article.montantHT);
  double get totalTVA => articles.fold(0, (sum, article) => sum + article.montantTVA);
  double get totalTTC => totalHT + totalTVA - remise;
}

class LigneAchat {
  final Article article;
  final int quantite;
  final double prixHT;
  final double tva;

  LigneAchat({
    required this.article,
    required this.quantite,
    required this.prixHT,
    this.tva = 20.0, // Valeur par défaut
  });

  factory LigneAchat.fromJson(Map<String, dynamic> json) {
    return LigneAchat(
      article: Article.fromJson(json['article'] as Map<String, dynamic>? ?? {}),
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
      prixHT: (json['prixHT'] as num?)?.toDouble() ?? 0,
      tva: (json['tva'] as num?)?.toDouble() ?? 20.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'article': article.toJson(),
    'quantite': quantite,
    'prixHT': prixHT,
    'tva': tva,
  };

  double get montantHT => prixHT * quantite;
  double get montantTVA => montantHT * (tva / 100);
  double get montantTTC => montantHT + montantTVA;
}