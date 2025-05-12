import 'dart:convert';

class Facture {
  final String numeroFacture;
  final String? idACH;
  final String? idV;
  final String? idF;
  final String? idP;
  final String? idCL;
  final String? idU;
  final DateTime dateCreation;
  final double prixHTV;
  final double TVA;
  final double prixTTC;
  final String type; // 'Achat' or 'Vente'
  final DateTime? dateEcheance;
  final String statut; // 'Brouillon', 'Émise', 'Payée', 'Annulée', 'En retard'
  final String? idDocument;

  Facture({
    required this.numeroFacture,
    this.idACH,
    this.idV,
    this.idF,
    this.idP,
    this.idCL,
    this.idU,
    DateTime? dateCreation,
    required this.prixHTV,
    required this.TVA,
    required this.prixTTC,
    required this.type,
    this.dateEcheance,
    this.statut = 'Brouillon',
    this.idDocument,
  }) : dateCreation = dateCreation ?? DateTime.now();

  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      numeroFacture: json['numero_facture'] ?? '',
      idACH: json['idACH'],
      idV: json['idV'],
      idF: json['idF'],
      idP: json['idP'],
      idCL: json['idCL'],
      idU: json['idU'],
      dateCreation:
          json['date_creation'] != null
              ? DateTime.parse(json['date_creation'])
              : DateTime.now(),
      prixHTV: (json['prixHTV'] as num).toDouble(),
      TVA: (json['TVA'] as num).toDouble(),
      prixTTC: (json['prixTTC'] as num).toDouble(),
      type: json['type'] ?? 'Achat',
      dateEcheance:
          json['date_echeance'] != null
              ? DateTime.tryParse(json['date_echeance'])
              : null,
      statut: json['statut'] ?? 'Brouillon',
      idDocument: json['id_document'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_facture': numeroFacture,
      'idACH': idACH,
      'idV': idV,
      'idF': idF,
      'idP': idP,
      'idCL': idCL,
      'idU': idU,
      'date_creation': dateCreation.toIso8601String(),
      'prixHTV': prixHTV,
      'TVA': TVA,
      'prixTTC': prixTTC,
      'type': type,
      'date_echeance': dateEcheance?.toIso8601String(),
      'statut': statut,
      'id_document': idDocument,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
