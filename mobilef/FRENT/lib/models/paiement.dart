import 'package:intl/intl.dart';

class PaiementFournisseur {
  final DateTime date;
  final double montantPaye;
  final String modePaiement;
  final String statut;

  PaiementFournisseur({
    required this.date,
    required this.montantPaye,
    required this.modePaiement,
    this.statut = 'Payé',
  });

  factory PaiementFournisseur.fromMap(Map<String, dynamic> map) {
    return PaiementFournisseur(
      date: DateTime.parse(map['date']),
      montantPaye: map['montantRecu'].toDouble(),
      modePaiement: map['modePaiement'],
      statut: map['statut'] ?? 'Payé',
    );
  }
  factory PaiementFournisseur.fromJson(Map<String, dynamic> json) {
    return PaiementFournisseur(
      date: DateTime.parse(json['date']),
      montantPaye: (json['montantPaye'] as num).toDouble(),
      modePaiement: json['modePaiement'],
      statut: json['statut'] ?? 'Payé',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'montantPaye': montantPaye,
      'modePaiement': modePaiement,
      'statut': statut,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'montantPaye': montantPaye,
      'modePaiement': modePaiement,
      'statut': statut,
    };
  }
}

class Paiement {
  final String id;
  final String reference;
  final DateTime datePaiement;
  final String responsable;
  final String? fournisseurId;
  final String? clientId;
  final double totalAPayer;
  final List<PaiementFournisseur> paiements;
  final double totalPaye;
  final double resteAPayer;
  final String? createdAt;
  Paiement({
    required this.id,
    required this.reference,
    required this.datePaiement,
    required this.responsable,
    this.fournisseurId,
    this.clientId,

    required this.totalAPayer,
    this.paiements = const [],
    this.totalPaye = 0,
    this.resteAPayer = 0,
    this.createdAt,
  });

  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: "101",
      reference: map['reference'],
      datePaiement: DateTime.parse(map['date']),
      responsable: map['responsable'],
      fournisseurId: map['fournisseurId'],
      totalAPayer: map['totalVente'].toDouble(),
      clientId: map['clientId'],
      paiements:
          (map['paiements'] as List)
              .map((p) => PaiementFournisseur.fromMap(p))
              .toList(),
      totalPaye: map['totalVente']?.toDouble() ?? 0.0,
      resteAPayer: map['resteAPayer']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'datePaiement': datePaiement.toIso8601String(),
      'responsable': responsable,
      'fournisseur': fournisseurId,
      'totalAPayer': totalAPayer,
      'paiements': paiements.map((p) => p.toMap()).toList(),
      'totalPaye': totalPaye,
      'resteAPayer': resteAPayer,
    };
  }

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['_id'],
      reference: json['reference'],
      datePaiement: DateTime.parse(json['datePaiement']),
      responsable: json['responsable'],
      clientId: json['clientId'] ?? '',
      fournisseurId: json['fournisseur'] ?? '',
      totalAPayer: (json['totalAPayer'] as num).toDouble(),
      paiements:
          (json['paiements'] as List<dynamic>)
              .map((e) => PaiementFournisseur.fromJson(e))
              .toList(),
      totalPaye: (json['totalPaye'] as num?)?.toDouble() ?? 0.0,
      resteAPayer: (json['resteAPayer'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'datePaiement': datePaiement.toIso8601String(),
      'responsable': responsable,
      'fournisseur': fournisseurId ?? '',
      'totalAPayer': totalAPayer,
      'paiements': paiements.map((p) => p.toJson()).toList(),
      'totalPaye': totalPaye,
      'resteAPayer': resteAPayer,
    };
  }
}
/*
class Paiement {
  final String id;
  final String reference;
  final String fournisseurId;
  final String responsable;
  final DateTime date;
  final double montantPaye;
  final String modePaiement;
  final String statut;
  final double totalAPayer;

  Paiement({
    required this.id,
    required this.reference,
    required this.fournisseurId,
    required this.responsable,
    required this.date,
    required this.montantPaye,
    required this.modePaiement,
    required this.statut,
    required this.totalAPayer,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? '',
      fournisseurId: json['fournisseurId'] ?? '',
      responsable: json['responsable'] ?? '',
      date: DateTime.parse(json['date']),
      montantPaye: (json['montantPaye'] ?? 0).toDouble(),
      modePaiement: json['modePaiement'] ?? '',
      statut: json['statut'] ?? '',
      totalAPayer: (json['totalAPayer'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reference': reference,
      'fournisseurId': fournisseurId,
      'responsable': responsable,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'montantPaye': montantPaye,
      'modePaiement': modePaiement,
      'statut': statut,
      'totalAPayer': totalAPayer,
    };
  }

  // Créer un Paiement à partir d’un Map
}
*/