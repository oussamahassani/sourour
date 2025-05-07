import 'dart:ui' as pw;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

import 'bonCommandeAchat.dart';

class BonDeCommande {
  final String id;
  final String reference;
  final DateTime date;
  final String fournisseur;
  final double totalHT;
  final double totalTTC;
  final List<ArticleCommande> articles;
  final String responsable;
  final String adresseLivraison;
  final String delaiLivraison;

  BonDeCommande({
    required this.id,
    required this.reference,
    required this.date,
    required this.fournisseur,
    required this.totalHT,
    required this.totalTTC,
    required this.articles,
    required this.responsable,
    required this.adresseLivraison,
    required this.delaiLivraison,
  });
}

class ArticleCommande {
  final String nom;
  final int quantite;
  final double prixHT;
  final double tva;
  final double montantHT;
  final double montantTTC;

  ArticleCommande({
    required this.nom,
    required this.quantite,
    required this.prixHT,
    required this.tva,
    required this.montantHT,
    required this.montantTTC,
  });
}

class BonDeCommandeHistoriqueScreen extends StatefulWidget {
  @override
  _BonDeCommandeHistoriqueScreenState createState() => _BonDeCommandeHistoriqueScreenState();
}

class _BonDeCommandeHistoriqueScreenState extends State<BonDeCommandeHistoriqueScreen> {
  final List<BonDeCommande> _bonDeCommandeList = [
    BonDeCommande(
      id: '1',
      reference: 'BC-001',
      date: DateTime.now().subtract(Duration(days: 10)),
      fournisseur: 'Fournisseur 1',
      totalHT: 1000.0,
      totalTTC: 1200.0,
      responsable: 'Jean Dupont',
      adresseLivraison: '123 Rue des Livraisons, Paris',
      delaiLivraison: '15 jours',
      articles: [
        ArticleCommande(
          nom: 'Article 1',
          quantite: 5,
          prixHT: 50.0,
          tva: 20.0,
          montantHT: 250.0,
          montantTTC: 300.0,
        ),
        ArticleCommande(
          nom: 'Article 2',
          quantite: 3,
          prixHT: 100.0,
          tva: 20.0,
          montantHT: 300.0,
          montantTTC: 360.0,
        ),
      ],
    ),
    BonDeCommande(
      id: '2',
      reference: 'BC-002',
      date: DateTime.now().subtract(Duration(days: 5)),
      fournisseur: 'Fournisseur 2',
      totalHT: 1500.0,
      totalTTC: 1800.0,
      responsable: 'Marie Martin',
      adresseLivraison: '456 Avenue des Commandes, Lyon',
      delaiLivraison: '10 jours',
      articles: [
        ArticleCommande(
          nom: 'Article 3',
          quantite: 2,
          prixHT: 200.0,
          tva: 20.0,
          montantHT: 400.0,
          montantTTC: 480.0,
        ),
        ArticleCommande(
          nom: 'Article 4',
          quantite: 4,
          prixHT: 75.0,
          tva: 20.0,
          montantHT: 300.0,
          montantTTC: 360.0,
        ),
      ],
    ),
  ];

  List<BonDeCommande> _filteredList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredList = _bonDeCommandeList;
  }

  void _filterList(String query) {
    setState(() {
      _filteredList = _bonDeCommandeList
          .where((bon) =>
              bon.reference.toLowerCase().contains(query.toLowerCase()) ||
              bon.fournisseur.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _supprimerBonDeCommande(BonDeCommande bon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de suppression'),
          content: Text('Voulez-vous vraiment supprimer ce bon de commande ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Supprimer'),
              onPressed: () {
                setState(() {
                  _bonDeCommandeList.removeWhere((item) => item.id == bon.id);
                  _filteredList.removeWhere((item) => item.id == bon.id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bon de commande supprimé'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<File> saveDocument(String name, pw.Document pdf) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _genererPDFDetaille(BonDeCommande bon) async {
    try {
      // Définition des couleurs personnalisées
      final PdfColor tealColor = PdfColor.fromHex('#008080');  // Teal
      final PdfColor greenColor = PdfColor.fromHex('#00A651'); // Vert
      final PdfColor whiteColor = PdfColors.white;             // Blanc
      final PdfColor blackColor = PdfColors.black;             // Noir
      final PdfColor lightTealColor = PdfColor.fromHex('#E0F2F1'); // Teal clair pour les arrière-plans

      // Charger le logo (remplacez par votre propre image)
      final ByteData logoData = await rootBundle.load('images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête avec logo et informations de l'entreprise
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      height: 80,
                      child: pw.Image(logoImage),
                    ),
                       pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Adresse: Rue dela nouvelle Delhi , Belvédére Tunis',
                        ),
                        pw.Text('Tél: 9230991'),
                        pw.Text(
                          'Email: contact@esprit-climatique.tn',
                        ),pw.Text(
                          'Matricule fiscale: 1883626X/A/M/000',
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.Divider(thickness: 2, color: tealColor),
                pw.SizedBox(height: 20),
                
                // Titre du document
                pw.Center(
                  child: pw.Text(
                    'BON DE COMMANDE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: tealColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Informations de la commande et du fournisseur
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Détails commande (côté gauche)
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: tealColor),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        padding: pw.EdgeInsets.all(15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('DÉTAILS DE LA COMMANDE',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: tealColor)),
                            pw.SizedBox(height: 10),
                            pw.Row(
                              children: [
                                pw.Text('Référence: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: blackColor)),
                                pw.Text(bon.reference, style: pw.TextStyle(color: blackColor)),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Date: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: blackColor)),
                                pw.Text(DateFormat('dd/MM/yyyy').format(bon.date), style: pw.TextStyle(color: blackColor)),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Responsable: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: blackColor)),
                                pw.Text(bon.responsable, style: pw.TextStyle(color: blackColor)),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Livraison: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: blackColor)),
                                pw.Text(bon.adresseLivraison, style: pw.TextStyle(color: blackColor)),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Délai: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: blackColor)),
                                pw.Text(bon.delaiLivraison, style: pw.TextStyle(color: blackColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    pw.SizedBox(width: 20),
                    
                    // Infos du fournisseur (côté droit)
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: tealColor),
                          borderRadius: pw.BorderRadius.circular(5),
                          color: lightTealColor,
                        ),
                        padding: pw.EdgeInsets.all(15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FOURNISSEUR',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: tealColor)),
                            pw.SizedBox(height: 10),
                            pw.Text(bon.fournisseur,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: blackColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                
                // Liste des articles
                pw.Text(
                  'Articles commandés',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    color: tealColor,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: tealColor,
                    width: 1,
                  ),
                  columnWidths: {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1.5),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1.5),
                    5: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: tealColor,
                        borderRadius: pw.BorderRadius.vertical(
                            top: pw.Radius.circular(5)),
                      ),
                      children: [
                        _headerCell('Article'),
                        _headerCell('Qté'),
                        _headerCell('Prix HT'),
                        _headerCell('TVA'),
                        _headerCell('Total HT'),
                        _headerCell('Total TTC'),
                      ],
                    ),
                    for (var article in bon.articles)
                      pw.TableRow(
  decoration: pw.BoxDecoration(
    color: bon.articles.indexOf(article) % 2 == 0 ? whiteColor : lightTealColor,
    border: pw.Border(
      bottom: pw.BorderSide(color: tealColor, width: 1),
    ),
  ),
  children: [
    _dataCell(article.nom, textColor: Colors.black),
    _dataCell(article.quantite.toString(), textColor: Colors.black),
    _dataCell('${article.prixHT.toStringAsFixed(2)} DT', textColor: Colors.black),
    _dataCell('${article.tva.toStringAsFixed(0)}%', textColor: Colors.black),
    _dataCell('${article.montantHT.toStringAsFixed(2)} DT', textColor: Colors.black),
    _dataCell('${article.montantTTC.toStringAsFixed(2)} DT', textColor: Colors.black),
  ],
),

                  ],
                ),
                pw.SizedBox(height: 20),
                
                // Totaux
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 300,
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: tealColor),
                        borderRadius: pw.BorderRadius.circular(5),
                        color: lightTealColor,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _totalLine('Sous-total HT:', bon.totalHT, textColor: Colors.black, valueColor: Colors.black),
                          _totalLine('TVA:', bon.totalTTC - bon.totalHT, textColor: Colors.black, valueColor: Colors.black),
                          pw.Divider(thickness: 1, color: tealColor),
                          _totalLine('Total HT:', bon.totalHT, isBold: true, textColor: Colors.black, valueColor: Colors.black),
                          _totalLine('Total TTC:', bon.totalTTC, isBold: true, isHighlighted: true, textColor: Colors.black, valueColor: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Notes et conditions
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: tealColor),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Conditions de paiement:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: tealColor)),
                      pw.SizedBox(height: 5),
                      pw.Text('Paiement à 30 jours à compter de la date de facture.', style: pw.TextStyle(color: blackColor)),
                      pw.SizedBox(height: 10),
                      pw.Text('Remarques:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: tealColor)),
                      pw.SizedBox(height: 5),
                      pw.Text('Cette commande est soumise à nos conditions générales d\'achat.', style: pw.TextStyle(color: blackColor)),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 40),
                
                // Signature
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Pour l\'Acheteur',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: tealColor)),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 200,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: tealColor)
                            )
                          ),
                          child: pw.Text(bon.responsable,
                              style: pw.TextStyle(
                                  decoration: pw.TextDecoration.underline,
                                  color: blackColor)),
                        ),
                        pw.Text('(Signature et cachet)',
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: blackColor)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Pour le Fournisseur',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: tealColor)),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 200,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: tealColor)
                            )
                          ),
                        ),
                        pw.Text('(Signature et cachet)',
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: blackColor)),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                pw.Footer(
                  margin: pw.EdgeInsets.only(top: 10),
                  trailing: pw.Text(
                    'Page ${context.pageNumber} sur ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 10, color: tealColor),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Sauvegarde du PDF
      final String filename = 'bon_de_commande_${bon.reference}.pdf';
      final file = await saveDocument(filename, pdf);
      
      // Ouverture du PDF
      if (file != null) {
        OpenFile.open(file.path);
      }
    } catch (e) {
      print('Erreur lors de la génération du PDF: $e');
    }
  }

  pw.Widget _headerCell(String text, {pw.Color textColor = Colors.white}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          
        )
      ),
    );
  }

  pw.Widget _dataCell(String text, {pw.Color textColor = Colors.black}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
         
        ),
      ),
    );
  }

  pw.Widget _totalLine(String label, double value, {bool isBold = false, bool isHighlighted = false, pw.Color textColor = Colors.black, pw.Color valueColor = Colors.black}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : null,
     
          ),
        ),
        pw.Text(
          '${value.toStringAsFixed(2)} dt',
          style: pw.TextStyle(
            fontWeight: isBold ? pw.FontWeight.bold : null,
           
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Bons de Commande'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par référence ou fournisseur',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterList('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
              onChanged: _filterList,
            ),
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      'Aucun bon de commande trouvé',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      final bon = _filteredList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ExpansionTile(
                          title: Text(
                            'Référence: ${bon.reference}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${DateFormat('dd/MM/yyyy').format(bon.date)}'),
                              Text('Fournisseur: ${bon.fournisseur}'),
                              Text('Total HT: ${bon.totalHT.toStringAsFixed(2)} €'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf, color: Colors.teal),
                                onPressed: () => _genererPDFDetaille(bon),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.teal),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BonDeCommandeScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.teal),
                                onPressed: () => _supprimerBonDeCommande(bon),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: bon.articles.map((article) {
                                  return ListTile(
                                    title: Text(article.nom),
                                    subtitle: Text(
                                        'Quantité: ${article.quantite} - Prix HT: ${article.prixHT.toStringAsFixed(2)} € - TVA: ${article.tva.toStringAsFixed(0)}%'),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BonDeCommandeScreen(),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}