import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'historiqueBCa.dart';

// Modèle de données pour un bon de commande
class BonDeCommande {
  final String id;
  final String reference;
  final String responsable;
  final DateTime date;
  final String fournisseur;
  final String adresseLivraison;
  final String delaiLivraison;
  final double remise;
  final double totalHT;
  final double totalTTC;
  final List<ArticleCommande> articles;

  BonDeCommande({
    required this.id,
    required this.reference,
    required this.responsable,
    required this.date,
    required this.fournisseur,
    required this.adresseLivraison,
    required this.delaiLivraison,
    required this.remise,
    required this.totalHT,
    required this.totalTTC,
    required this.articles,
  });
}

// Modèle de données pour les articles d'un bon de commande
class ArticleCommande {
  final String nom;
  final int quantite;
  final double prixHT;
  final double tva;

  ArticleCommande({
    required this.nom,
    required this.quantite,
    required this.prixHT,
    required this.tva,
  });
}

class BonDeCommandeScreen extends StatefulWidget {
  final BonDeCommande? bonDeCommande;
  final Function(BonDeCommande)? onSave;

  const BonDeCommandeScreen({Key? key, this.bonDeCommande, this.onSave})
    : super(key: key);

  @override
  _BonDeCommandeScreenState createState() => _BonDeCommandeScreenState();
}

class _BonDeCommandeScreenState extends State<BonDeCommandeScreen> {
  late TextEditingController _responsableController;
  late TextEditingController _referenceController;
  late TextEditingController _adresseLivraisonController;
  late TextEditingController _remiseController;
  late TextEditingController _delaiLivraisonController;

  late DateTime _selectedDate;
  String? _selectedFournisseur;
  bool _isTTC = false;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalCommande = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;

  // Liste de fournisseurs existants
  List<String> _fournisseurs = ['Fournisseur 1', 'Fournisseur 2'];

  // Liste des articles existants avec les prix HT par défaut
  List<Map<String, dynamic>> _listeArticles = [
    {'nom': 'Article 1', 'prixHT': 50.0},
    {'nom': 'Article 2', 'prixHT': 30.0},
    {'nom': 'Article 3', 'prixHT': 20.0},
  ];

  String? _selectedArticle;
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController(
    text: '20.0',
  );

  // Formatter pour les montants
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec les valeurs existantes ou des valeurs par défaut
    _referenceController = TextEditingController(
      text:
          widget.bonDeCommande?.reference ??
          'BC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
    );
    _responsableController = TextEditingController(
      text: widget.bonDeCommande?.responsable ?? '',
    );
    _adresseLivraisonController = TextEditingController(
      text: widget.bonDeCommande?.adresseLivraison ?? '',
    );
    _remiseController = TextEditingController(
      text: widget.bonDeCommande?.remise.toString() ?? '0',
    );
    _delaiLivraisonController = TextEditingController(
      text: widget.bonDeCommande?.delaiLivraison ?? '',
    );

    _selectedDate = widget.bonDeCommande?.date ?? DateTime.now();
    _selectedFournisseur = widget.bonDeCommande?.fournisseur;

    // Si on est en mode édition, pré-remplir les articles
    if (widget.bonDeCommande != null) {
      _articles =
          widget.bonDeCommande!.articles.map((article) {
            return {
              'nom': article.nom,
              'quantite': article.quantite,
              'prixHT': article.prixHT,
              'tva': article.tva,
              'prixTTC': article.prixHT * (1 + article.tva / 100),
              'montantHT': article.prixHT * article.quantite,
              'montantTVA':
                  article.prixHT * article.quantite * (article.tva / 100),
              'montantTTC':
                  article.prixHT * article.quantite * (1 + article.tva / 100),
            };
          }).toList();
    }

    _calculerTotal();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _responsableController.dispose();
    _adresseLivraisonController.dispose();
    _remiseController.dispose();
    _delaiLivraisonController.dispose();
    _prixController.dispose();
    _quantiteController.dispose();
    _tvaController.dispose();
    super.dispose();
  }

  // Fonction pour ajouter un article à la liste
  void _ajouterArticle(Map<String, dynamic> article) {
    setState(() {
      double prixHT = article['prixHT'];
      double tva = article['tva'];
      int quantite = article['quantite'];
      double prixTTC = prixHT * (1 + tva / 100);

      _articles.add({
        'nom': article['nom'],
        'quantite': quantite,
        'prixHT': prixHT,
        'tva': tva,
        'prixTTC': prixTTC,
        'montantHT': prixHT * quantite,
        'montantTVA': prixHT * quantite * (tva / 100),
        'montantTTC': prixTTC * quantite,
      });
      _calculerTotal();

      // Réinitialiser les champs
      _selectedArticle = null;
      _prixController.clear();
      _quantiteController.clear();
      _tvaController.text = '20.0';
    });
  }

  // Calcul du total
  void _calculerTotal() {
    double sousTotal = _articles.fold(
      0.0,
      (sum, article) => sum + article['montantHT'],
    );

    double totalTVA = _articles.fold(
      0.0,
      (sum, article) => sum + article['montantTVA'],
    );

    double remise = double.tryParse(_remiseController.text) ?? 0.0;

    setState(() {
      _sousTotal = sousTotal;
      _totalTVA = totalTVA;
      _totalHT = sousTotal - remise; // Total HT avec remise
      _totalCommande = sousTotal + totalTVA - remise; // Total TTC avec remise
    });
  }

  // Supprimer un article de la liste
  void _supprimerArticle(int index) {
    setState(() {
      _articles.removeAt(index);
      _calculerTotal();
    });
  }

  // Sélection de la date de commande
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Enregistrer la commande
  void _enregistrerCommande() {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      final bonDeCommande = BonDeCommande(
        id:
            widget.bonDeCommande?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        reference: _referenceController.text,
        responsable: _responsableController.text,
        date: _selectedDate,
        fournisseur: _selectedFournisseur!,
        adresseLivraison: _adresseLivraisonController.text,
        delaiLivraison: _delaiLivraisonController.text,
        remise: double.parse(_remiseController.text),
        totalHT: _totalHT,
        totalTTC: _totalCommande,
        articles:
            _articles
                .map(
                  (article) => ArticleCommande(
                    nom: article['nom'],
                    quantite: article['quantite'],
                    prixHT: article['prixHT'],
                    tva: article['tva'],
                  ),
                )
                .toList(),
      );

      if (widget.onSave != null) {
        widget.onSave!(bonDeCommande);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.bonDeCommande == null
                ? "Commande enregistrée avec succès"
                : "Commande modifiée avec succès",
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      // Si c'est une nouvelle commande, réinitialiser le formulaire
      if (widget.bonDeCommande == null) {
        _formKey.currentState!.reset();
        setState(() {
          _articles.clear();
          _selectedDate = DateTime.now();
          _selectedFournisseur = null;
          _calculerTotal();
        });
      }
    } else if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un article"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Générer un PDF
 // Ajoutons d'abord les contrôleurs nécessaires pour les informations du fournisseur
// Ces lignes devraient être ajoutées à la déclaration des autres contrôleurs dans votre classe

final TextEditingController _fournisseurNomController = TextEditingController();
final TextEditingController _fournisseurAdresseController = TextEditingController();
final TextEditingController _fournisseurVilleController = TextEditingController();
final TextEditingController _fournisseurCodePostalController = TextEditingController();
final TextEditingController _fournisseurEmailController = TextEditingController();
final TextEditingController _fournisseurTelController = TextEditingController();
final TextEditingController _fournisseurSiretController = TextEditingController();

// Remplaçons maintenant la méthode de génération PDF

Future<void> _genererPDF() async {
  if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
    try {
      // Charger le logo (remplacez par votre propre image)
      final ByteData logoData = await rootBundle.load('assets/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();

      // Police personnalisée (optionnel)
      final pw.Font font = await pw.Font.ttf(await rootBundle.load('assets/fonts/roboto.ttf'));

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
                        pw.Text('ENTREPRISE XYZ',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 18)),
                        pw.SizedBox(height: 5),
                        pw.Text('123 Rue de l\'Exemple',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('75000 Paris, France',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text('Tél: 01 23 45 67 89',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Email: contact@entreprisexyz.com',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('SIRET: 123 456 789 00010',
                            style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                
                // Titre du document
                pw.Center(
                  child: pw.Text(
                    'BON DE COMMANDE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: PdfColors.blue800,
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
                          border: pw.Border.all(color: PdfColors.grey300),
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
                                    color: PdfColors.blue800)),
                            pw.SizedBox(height: 10),
                            pw.Row(
                              children: [
                                pw.Text('Référence: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(_referenceController.text),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Date: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate)),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Responsable: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(_responsableController.text),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Livraison: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(_adresseLivraisonController.text),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Délai: ',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text(_delaiLivraisonController.text),
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
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                          color: PdfColors.blue50,
                        ),
                        padding: pw.EdgeInsets.all(15),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('FOURNISSEUR',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: PdfColors.blue800)),
                            pw.SizedBox(height: 10),
                            pw.Text(_fournisseurNomController.text,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 5),
                            pw.Text(_fournisseurAdresseController.text),
                            pw.Text('${_fournisseurCodePostalController.text} ${_fournisseurVilleController.text}'),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              children: [
                                pw.Text('Tél: ',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(_fournisseurTelController.text),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Text('Email: ',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(_fournisseurEmailController.text),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Text('SIRET: ',
                                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(_fournisseurSiretController.text),
                              ],
                            ),
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
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
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
                        color: PdfColors.teal,
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
                    for (var article in _articles)
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                                color: PdfColors.grey200, width: 1),
                          ),
                        ),
                        children: [
                          _dataCell(article['nom']),
                          _dataCell(article['quantite'].toString()),
                          _dataCell('${article['prixHT'].toStringAsFixed(2)} €'),
                          _dataCell('${article['tva']}%'),
                          _dataCell('${article['montantHT'].toStringAsFixed(2)} €'),
                          _dataCell('${article['montantTTC'].toStringAsFixed(2)} €'),
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
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _totalLine('Sous-total HT:', _sousTotal),
                          _totalLine('TVA:', _totalTVA),
                          if (double.parse(_remiseController.text) > 0)
                            _totalLine('Remise:', -double.parse(_remiseController.text)),
                          pw.Divider(thickness: 1),
                          _totalLine('Total HT:', _totalHT, isBold: true),
                          _totalLine('Total TTC:', _totalCommande, isBold: true, isHighlighted: true),
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
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Conditions de paiement:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Paiement à 30 jours à compter de la date de facture.'),
                      pw.SizedBox(height: 10),
                      pw.Text('Remarques:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Cette commande est soumise à nos conditions générales d\'achat.'),
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
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 200,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.black)
                            )
                          ),
                          child: pw.Text(_responsableController.text,
                              style: pw.TextStyle(
                                  decoration: pw.TextDecoration.underline)),
                        ),
                        pw.Text('(Signature et cachet)',
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Pour le Fournisseur',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 200,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.black)
                            )
                          ),
                        ),
                        pw.Text('(Signature et cachet)',
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                pw.Footer(
                  margin: pw.EdgeInsets.only(top: 10),
                  trailing: pw.Text(
                    'Page ${context.pageNumber} sur ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Enregistrer le PDF
      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/commande_${_referenceController.text}_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Ouvrir le PDF
      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF généré avec succès"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la génération du PDF: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else if (_articles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Veuillez ajouter au moins un article"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Fonctions helper pour le style
pw.Padding _headerCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    ),
  );
}

pw.Padding _dataCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(text),
  );
}

pw.Widget _totalLine(String label, double value, {bool isBold = false, bool isHighlighted = false}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: isHighlighted ? PdfColors.blue800 : null,
            )),
        pw.Text('${value.toStringAsFixed(2)} €',
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: isHighlighted ? PdfColors.blue800 : null,
            )),
      ],
    ),
  );
}
  // Fonction pour naviguer vers l'historique des commandes
  void _naviguerVersHistorique(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BonDeCommandeHistoriqueScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bonDeCommande == null
              ? 'Nouveau Bon de Commande'
              : 'Modifier Bon de Commande',
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _naviguerVersHistorique(context),
            tooltip: 'Historique des commandes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations Générales
              _buildSectionHeader('Informations Générales', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      isSmallScreen
                          ? Column(
                            children: [
                              TextFormField(
                                controller: _referenceController,
                                decoration: InputDecoration(
                                  labelText: 'Numéro de référence',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.numbers),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 12.0,
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _referenceController,
                                  decoration: InputDecoration(
                                    labelText: 'Numéro de référence',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.numbers),
                                  ),
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Champ requis'
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      SizedBox(height: !isSmallScreen ? 16.0 : 8.0),
                      TextFormField(
                        controller: _responsableController,
                        decoration: InputDecoration(
                          labelText: 'Responsable de commande',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      TextFormField(
                        controller: _adresseLivraisonController,
                        decoration: InputDecoration(
                          labelText: 'Adresse de livraison',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                        maxLines: 2,
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      TextFormField(
                        controller: _delaiLivraisonController,
                        decoration: InputDecoration(
                          labelText: 'Délai de livraison',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Section Fournisseur
              _buildSectionHeader('Fournisseur', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedFournisseur,
                        onChanged:
                            (value) =>
                                setState(() => _selectedFournisseur = value),
                        items:
                            _fournisseurs
                                .map(
                                  (f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(
                                      f,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un fournisseur',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        validator:
                            (value) => value == null ? 'Champ requis' : null,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Section Articles
              _buildSectionHeader('Articles', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedArticle,
                        onChanged: (value) {
                          setState(() {
                            _selectedArticle = value;
                            var article = _listeArticles.firstWhere(
                              (article) => article['nom'] == value,
                              orElse: () => {'prixHT': 0.0},
                            );
                            _prixController.text = article['prixHT'].toString();
                          });
                        },
                        items:
                            _listeArticles
                                .map(
                                  (article) => DropdownMenuItem<String>(
                                    value: article['nom'],
                                    child: Text(
                                      article['nom'],
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un article',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        isExpanded: true,
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),

                      isSmallScreen
                          ? Column(
                            children: [
                              TextFormField(
                                controller: _quantiteController,
                                decoration: InputDecoration(
                                  labelText: 'Quantité',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.format_list_numbered),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) <= 0) {
                                    return 'Quantité invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _prixController,
                                decoration: InputDecoration(
                                  labelText: 'Prix HT',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Prix invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _tvaController,
                                decoration: InputDecoration(
                                  labelText: 'TVA (%)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.percent),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) < 0) {
                                    return 'TVA invalide';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _quantiteController,
                                  decoration: InputDecoration(
                                    labelText: 'Quantité',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(
                                      Icons.format_list_numbered,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (int.tryParse(value) == null ||
                                        int.parse(value) <= 0) {
                                      return 'Quantité invalide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _prixController,
                                  decoration: InputDecoration(
                                    labelText: 'Prix HT',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (double.tryParse(value) == null ||
                                        double.parse(value) <= 0) {
                                      return 'Prix invalide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _tvaController,
                                  decoration: InputDecoration(
                                    labelText: 'TVA (%)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.percent),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (double.tryParse(value) == null ||
                                        double.parse(value) < 0) {
                                      return 'TVA invalide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedArticle != null &&
                              _quantiteController.text.isNotEmpty &&
                              _prixController.text.isNotEmpty &&
                              _tvaController.text.isNotEmpty) {
                            _ajouterArticle({
                              'nom': _selectedArticle!,
                              'quantite': int.parse(_quantiteController.text),
                              'prixHT': double.parse(_prixController.text),
                              'tva': double.parse(_tvaController.text),
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  )
                                  : null,
                        ),
                        child: Text(
                          'Ajouter l\'article',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Liste des articles ajoutés
              if (_articles.isNotEmpty) ...[
                _buildSectionHeader('Liste des Articles', isSmallScreen),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                    child: Column(
                      children: [
                        for (var i = 0; i < _articles.length; i++)
                          ListTile(
                            title: Text(
                              _articles[i]['nom'],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                            subtitle: Text(
                              'Quantité: ${_articles[i]['quantite']} - Prix HT: ${currencyFormat.format(_articles[i]['prixHT'])} - TVA: ${_articles[i]['tva']}%',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () => _supprimerArticle(i),
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Section Remise et Totaux
              _buildSectionHeader('Totaux', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _remiseController,
                        decoration: InputDecoration(
                          labelText: 'Remise (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.discount),
                          contentPadding:
                              isSmallScreen
                                  ? EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 12.0,
                                  )
                                  : null,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculerTotal(),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Champ requis';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 0) {
                            return 'Remise invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      Text(
                        'Sous-total HT: ${currencyFormat.format(_sousTotal)}',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      Text(
                        'TVA: ${currencyFormat.format(_totalTVA)}',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      if (double.parse(_remiseController.text) > 0)
                        Text(
                          'Remise: -${currencyFormat.format(double.parse(_remiseController.text))}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.red,
                          ),
                        ),
                      Divider(),
                      Text(
                        'Total HT: ${currencyFormat.format(_totalHT)}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total TTC: ${currencyFormat.format(_totalCommande)}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _enregistrerCommande,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding:
                          isSmallScreen
                              ? EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              )
                              : null,
                    ),
                    child: Text(
                      widget.bonDeCommande == null
                          ? 'Enregistrer'
                          : 'Mettre à jour',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _genererPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      padding:
                          isSmallScreen
                              ? EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              )
                              : null,
                    ),
                    child: Text(
                      'Générer PDF',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 16.0),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction pour créer un en-tête de section
  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(
        top: isSmallScreen ? 8.0 : 16.0,
        bottom: isSmallScreen ? 4.0 : 8.0,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 22,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}
