import 'package:intl/intl.dart';

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
}
