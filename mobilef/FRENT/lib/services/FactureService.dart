import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/facture.dart';

class FactureService {
  // Listes de données pour simulation
  static List<FactureVente> _facturesVente = [
    FactureVente(
      id: '1',
      numeroFacture: 'FV-2025-001',
      client: 'Client 1',
      produit: 'Produit A',
      prixHT: 1000.0,
      tva: 20.0,
      prixTTC: 1200.0,
      statut: 'Payée',
      dateCreation: DateTime.now().subtract(Duration(days: 30)),
      dateEcheance: DateTime.now().add(Duration(days: 15)),
      createur: 'User 1',
    ),
    FactureVente(
      id: '2',
      numeroFacture: 'FV-2025-002',
      client: 'Client 2',
      produit: 'Produit B',
      prixHT: 2500.0,
      tva: 20.0,
      prixTTC: 3000.0,
      statut: 'En retard',
      dateCreation: DateTime.now().subtract(Duration(days: 45)),
      dateEcheance: DateTime.now().subtract(Duration(days: 5)),
      createur: 'User 1',
    ),
  ];

  static List<FactureAchat> _facturesAchat = [
    FactureAchat(
      id: '1',
      numeroFacture: 'FA-2025-001',
      fournisseur: 'Fournisseur 1',
      produit: 'Produit A',
      prixHT: 1000.0,
      tva: 20.0,
      prixTTC: 1200.0,
      statut: 'Payée',
      dateCreation: DateTime.now().subtract(Duration(days: 30)),
      dateEcheance: DateTime.now().add(Duration(days: 15)),
      createur: 'User 1',
    ),
    FactureAchat(
      id: '2',
      numeroFacture: 'FA-2025-002',
      fournisseur: 'Fournisseur 2',
      produit: 'Produit B',
      prixHT: 2500.0,
      tva: 20.0,
      prixTTC: 3000.0,
      statut: 'En retard',
      dateCreation: DateTime.now().subtract(Duration(days: 45)),
      dateEcheance: DateTime.now().subtract(Duration(days: 5)),
      createur: 'User 1',
    ),
  ];

  // Méthodes pour les factures de vente
  static List<FactureVente> getFacturesVente() => _facturesVente;
  
  static void ajouterFactureVente(FactureVente facture) {
    _facturesVente.add(facture);
  }

  static void mettreAJourFactureVente(FactureVente facture) {
    final index = _facturesVente.indexWhere((f) => f.id == facture.id);
    if (index != -1) {
      _facturesVente[index] = facture;
    }
  }

  // Méthodes pour les factures d'achat
  static List<FactureAchat> getFacturesAchat() => _facturesAchat;
  
  static void ajouterFactureAchat(FactureAchat facture) {
    _facturesAchat.add(facture);
  }

  static void mettreAJourFactureAchat(FactureAchat facture) {
    final index = _facturesAchat.indexWhere((f) => f.id == facture.id);
    if (index != -1) {
      _facturesAchat[index] = facture;
    }
  }

  // Méthode générique pour générer un PDF
  static Future<String> genererPDF(Facture facture) async {
    final pdf = pw.Document();
    final isVente = facture is FactureVente;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'FACTURE ${facture.typeFacture.toUpperCase()}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Notre Société', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('123 Rue de Commerce'),
                      pw.Text('75000 Paris'),
                      pw.Text('France'),
                      pw.Text('contact@notresociete.fr'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Facture N°: ${facture.numeroFacture}'),
                      pw.Text('Date d\'émission: ${DateFormat('dd/MM/yyyy').format(facture.dateCreation)}'),
                      pw.Text('Date d\'échéance: ${DateFormat('dd/MM/yyyy').format(facture.dateEcheance)}'),
                      pw.Text('Statut: ${facture.statut}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(isVente ? 'Client:' : 'Fournisseur:', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(isVente 
                      ? (facture as FactureVente).client 
                      : (facture as FactureAchat).fournisseur),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // En-tête
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isVente ? PdfColors.blue : PdfColors.teal),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Produit', 
                          style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Prix HT (€)', 
                          style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('TVA (%)', 
                          style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Prix TTC (€)', 
                          style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Données
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(facture.produit),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(facture.prixHT.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(facture.tva.toStringAsFixed(2)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(facture.prixTTC.toStringAsFixed(2)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Montant HT: ${facture.prixHT.toStringAsFixed(2)} €'),
                      pw.Text('TVA (${facture.tva}%): ${(facture.prixTTC - facture.prixHT).toStringAsFixed(2)} €'),
                      pw.Divider(),
                      pw.Text('Montant total: ${facture.prixTTC.toStringAsFixed(2)} €', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text('Facture générée par: ${facture.createur}'),
              pw.SizedBox(height: 20),
              pw.Footer(
                title: pw.Text('Merci pour votre confiance', 
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),)
            ],
          );
        },
      ),
    );

    // Enregistrer le fichier
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/facture_${facture.numeroFacture}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  // Méthodes utilitaires
  static Color getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payée':
        return Colors.green;
      case 'émise':
        return Colors.blue;
      case 'en retard':
        return Colors.red;
      case 'annulée':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  
}
