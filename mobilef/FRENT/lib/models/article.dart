class Article {
  final String id;
  final String nomArticle;
  final String reference;
  final double prixVente;
  final double prixAchat;
  final double tauxMarge;
  final int stock;
  final int? seuilAlerte;
  final String? categorie;
  final String? type;
  final String? description;
  final String? image;
  final DateTime? dateAjout;

  Article({
    required this.id,
    required this.nomArticle,
    required this.reference,
    required this.prixVente,
    required this.prixAchat,
    required this.tauxMarge,
    required this.stock,
    this.seuilAlerte,
    this.categorie,
    this.type,
    this.description,
    this.image,
    this.dateAjout,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'] ?? json['id'] ?? '',
      nomArticle: json['nomArticle'] ?? '',
      reference: json['reference'] ?? '',
      prixVente: _toDouble(json['prixVente']),
      prixAchat: _toDouble(json['prixAchat']),
      tauxMarge: _toDouble(json['tauxMarge']),
      stock: _toInt(json['stock']),
      seuilAlerte: _toInt(json['seuilAlerte']),
      categorie: json['categorie'],
      type: json['type'],
      description: json['description'],
      image: json['image'],
      dateAjout: json['dateAjout'] != null 
          ? DateTime.parse(json['dateAjout']) 
          : null,
    );
  }

  get idArticle => null;

  get quantite => null;

  get quantiteStock => null;

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomArticle': nomArticle,
    'reference': reference,
    'prixVente': prixVente,
    'prixAchat': prixAchat,
    'tauxMarge': tauxMarge,
    'stock': stock,
    'seuilAlerte': seuilAlerte,
    'categorie': categorie,
    'type': type,
    'description': description,
    'image': image,
    'dateAjout': dateAjout?.toIso8601String(),
  };
}