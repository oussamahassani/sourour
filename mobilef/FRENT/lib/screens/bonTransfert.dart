import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// Modèle Article
class Article {
  final String reference;
  final String libelle;
  final double quantite;
  final double? prix;
  final String? observations;

  Article({
    required this.reference,
    required this.libelle,
    required this.quantite,
    this.prix,
    this.observations,
  });

  double get montant => (prix ?? 0) * quantite;

  Article copyWith({
    String? reference,
    String? libelle,
    double? quantite,
    double? prix,
    String? observations,
  }) {
    return Article(
      reference: reference ?? this.reference,
      libelle: libelle ?? this.libelle,
      quantite: quantite ?? this.quantite,
      prix: prix ?? this.prix,
      observations: observations ?? this.observations,
    );
  }
}

// Modèle Bon de Transfert
class BonTransfert {
  final String reference;
  final String entrepotSource;
  final String entrepotDestination;
  final DateTime dateTransfert;
  final String statut;
  final List<Article> articles;
  final DateTime dateCreation;

  BonTransfert({
    required this.reference,
    required this.entrepotSource,
    required this.entrepotDestination,
    required this.dateTransfert,
    required this.statut,
    required this.articles,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  double get montantTotal {
    return articles.fold(0, (sum, article) => sum + article.montant);
  }
}

// Page principale des Bons de Transfert
class BonTransfertPage extends StatefulWidget {
  @override
  _BonTransfertPageState createState() => _BonTransfertPageState();
}

class _BonTransfertPageState extends State<BonTransfertPage> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _entrepotSourceController = TextEditingController();
  final _entrepotDestinationController = TextEditingController();
  
  DateTime? _dateTransfert;
  String? _statut = 'En attente';

  List<Article> _articles = [];
  List<BonTransfert> _historiqueBons = [];

  final List<String> _statuts = [
    'En attente',
    'En cours',
    'Terminé',
    'Annulé'
  ];

  @override
  void initState() {
    super.initState();
    // Exemples d'articles
    _articles = [
      Article(reference: 'AMPHTOR', libelle: 'Ampoule torsadée Halogène', quantite: 152.40),
      Article(reference: 'AMPINFR', libelle: 'Ampoule infrarouge', quantite: 48.00),
    ];
    
    // Exemples d'historique
    _historiqueBons = [
      BonTransfert(
        reference: 'BT-2023-001',
        entrepotSource: 'Entrepôt Principal',
        entrepotDestination: 'Entrepôt Secondaire',
        dateTransfert: DateTime.now().subtract(Duration(days: 3)),
        statut: 'Terminé',
        articles: [
          Article(reference: 'ART001', libelle: 'Article 1', quantite: 10, prix: 15.99),
          Article(reference: 'ART002', libelle: 'Article 2', quantite: 5, prix: 24.50),
        ],
      ),
      BonTransfert(
        reference: 'BT-2023-002',
        entrepotSource: 'Entrepôt Secondaire',
        entrepotDestination: 'Entrepôt Tertiaire',
        dateTransfert: DateTime.now().subtract(Duration(days: 1)),
        statut: 'En cours',
        articles: [
          Article(reference: 'ART003', libelle: 'Article 3', quantite: 20),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _entrepotSourceController.dispose();
    _entrepotDestinationController.dispose();
    super.dispose();
  }

  void _naviguerVersHistorique() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoriqueBonsTransfertPage(historiqueBons: _historiqueBons),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTransfert ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateTransfert) {
      setState(() {
        _dateTransfert = picked;
      });
    }
  }

  void _addArticle() {
    showDialog(
      context: context,
      builder: (context) {
        String reference = '';
        String libelle = '';
        double quantite = 0;
        double? prix;
        String? observations;

        return AlertDialog(
          title: Text('Ajouter un article', style: TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Référence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.code, color: Colors.teal),
                  ),
                  onChanged: (value) => reference = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Libellé',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: Colors.teal),
                  ),
                  onChanged: (value) => libelle = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => quantite = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Prix (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => prix = double.tryParse(value),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Observations (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note, color: Colors.teal),
                  ),
                  onChanged: (value) => observations = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                if (reference.isNotEmpty && libelle.isNotEmpty && quantite > 0) {
                  setState(() {
                    _articles.add(Article(
                      reference: reference,
                      libelle: libelle,
                      quantite: quantite,
                      prix: prix,
                      observations: observations,
                    ));
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _editArticle(int index) {
    final article = _articles[index];
    showDialog(
      context: context,
      builder: (context) {
        String reference = article.reference;
        String libelle = article.libelle;
        double quantite = article.quantite;
        double? prix = article.prix;
        String? observations = article.observations;

        return AlertDialog(
          title: Text('Modifier l\'article', style: TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: reference,
                  decoration: InputDecoration(
                    labelText: 'Référence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.code, color: Colors.teal),
                  ),
                  onChanged: (value) => reference = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: libelle,
                  decoration: InputDecoration(
                    labelText: 'Libellé',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description, color: Colors.teal),
                  ),
                  onChanged: (value) => libelle = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: quantite.toString(),
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => quantite = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: prix?.toString(),
                  decoration: InputDecoration(
                    labelText: 'Prix (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => prix = double.tryParse(value),
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: observations,
                  decoration: InputDecoration(
                    labelText: 'Observations (optionnel)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note, color: Colors.teal),
                  ),
                  onChanged: (value) => observations = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () {
                if (reference.isNotEmpty && libelle.isNotEmpty && quantite > 0) {
                  setState(() {
                    _articles[index] = Article(
                      reference: reference,
                      libelle: libelle,
                      quantite: quantite,
                      prix: prix,
                      observations: observations,
                    );
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                  );
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _removeArticle(int index) {
    setState(() {
      _articles.removeAt(index);
    });
  }

  void _enregistrerBonTransfert() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_dateTransfert == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une date de transfert')),
      );
      return;
    }
    
    if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ajouter au moins un article')),
      );
      return;
    }

    final nouveauBon = BonTransfert(
      reference: _referenceController.text,
      entrepotSource: _entrepotSourceController.text,
      entrepotDestination: _entrepotDestinationController.text,
      dateTransfert: _dateTransfert!,
      statut: _statut!,
      articles: List.from(_articles),
    );

    setState(() {
      _historiqueBons.add(nouveauBon);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bon de transfert enregistré avec succès')),
    );
    
    _formKey.currentState?.reset();
    _referenceController.clear();
    _entrepotSourceController.clear();
    _entrepotDestinationController.clear();
    setState(() {
      _dateTransfert = null;
      _statut = 'En attente';
      _articles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bon de Transfert', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _naviguerVersHistorique,
            tooltip: 'Historique',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _enregistrerBonTransfert,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations Générales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          labelText: 'Référence Bon de Transfert',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number, color: Colors.teal),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une référence';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _entrepotSourceController,
                              decoration: InputDecoration(
                                labelText: 'Entrepôt Source',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.home_work, color: Colors.teal),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un entrepôt source';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _entrepotDestinationController,
                              decoration: InputDecoration(
                                labelText: 'Entrepôt Destination',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un entrepôt destination';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date de Transfert',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                ),
                                child: Text(
                                  _dateTransfert == null
                                      ? 'Choisir une date'
                                      : DateFormat('dd/MM/yyyy').format(_dateTransfert!),
                                ),
                              ),
                            ),),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Statut',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.flag, color: Colors.teal),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.teal),
                                  ),
                                ),
                                value: _statut,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _statut = newValue;
                                  });
                                },
                                items: _statuts.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez sélectionner un statut';
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Articles',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Ajouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              onPressed: _addArticle,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _articles.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Aucun article ajouté',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _articles.length,
                                itemBuilder: (context, index) {
                                  final article = _articles[index];
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(
                                        '${article.reference} - ${article.libelle}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Quantité: ${article.quantite.toStringAsFixed(2)}' +
                                            (article.prix != null
                                                ? ' | Prix: ${article.prix!.toStringAsFixed(2)} | Montant: ${article.montant.toStringAsFixed(2)}'
                                                : ''),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.teal),
                                            onPressed: () => _editArticle(index),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _removeArticle(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Enregistrer le Bon de Transfert'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _enregistrerBonTransfert,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

// Page d'historique des Bons de Transfert
class HistoriqueBonsTransfertPage extends StatefulWidget {
  final List<BonTransfert> historiqueBons;

  HistoriqueBonsTransfertPage({required this.historiqueBons});

  @override
  _HistoriqueBonsTransfertPageState createState() => _HistoriqueBonsTransfertPageState();
}

class _HistoriqueBonsTransfertPageState extends State<HistoriqueBonsTransfertPage> {
  late List<BonTransfert> _filteredBons;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBons = widget.historiqueBons;
    _searchController.addListener(_filterBons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBons = widget.historiqueBons.where((bon) {
        return bon.reference.toLowerCase().contains(query) ||
               bon.entrepotSource.toLowerCase().contains(query) ||
               bon.entrepotDestination.toLowerCase().contains(query) ||
               bon.statut.toLowerCase().contains(query);
      }).toList();
    });
  }
  Future<void> _generatePdf(BonTransfert bon) async {
  try {
    // Définition des couleurs personnalisées
    final PdfColor tealColor = PdfColor.fromHex('#008080');  // Teal
    final PdfColor greenColor = PdfColor.fromHex('#00A651'); // Vert
    final PdfColor whiteColor = PdfColors.white;             // Blanc
    final PdfColor blackColor = PdfColors.black;            // Noir
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
                      ),
                      pw.Text(
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
                  'BON DE TRANSFERT',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                    color: tealColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Informations du transfert
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Détails du transfert (côté gauche)
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
                          pw.Text('DÉTAILS DU TRANSFERT',
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
                              pw.Text(DateFormat('dd/MM/yyyy').format(bon.dateTransfert), style: pw.TextStyle(color: blackColor)),
                            ],
                          ),
                          pw.SizedBox(height: 8),
                          pw.Row(
                            children: [
                              pw.Text('Statut: ',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: blackColor)),
                              pw.Text(bon.statut, style: pw.TextStyle(color: blackColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  pw.SizedBox(width: 20),
                  
                  // Infos des entrepôts (côté droit)
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
                          pw.Text('ENTREPÔTS',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14,
                                  color: tealColor)),
                          pw.SizedBox(height: 10),
                          pw.Text('Source: ${bon.entrepotSource}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: blackColor)),
                          pw.SizedBox(height: 8),
                          pw.Text('Destination: ${bon.entrepotDestination}',
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
                'Articles transférés',
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
                  0: pw.FlexColumnWidth(1.5),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(1.5),
                  5: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: tealColor,
                      borderRadius: pw.BorderRadius.vertical(
                          top: pw.Radius.circular(5)),
                    ),
                    children: [
                      _headerCell('Référence'),
                      _headerCell('Libellé'),
                      _headerCell('Qté'),
                      _headerCell('Prix'),
                      _headerCell('Montant'),
                      _headerCell('Observations'),
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
                        _dataCell(article.reference, textColor: blackColor),
                        _dataCell(article.libelle, textColor: blackColor),
                        _dataCell(article.quantite.toStringAsFixed(2), textColor: blackColor),
                        _dataCell(article.prix != null ? article.prix!.toStringAsFixed(2) : '', textColor: blackColor),
                        _dataCell(article.montant > 0 ? article.montant.toStringAsFixed(2) : '', textColor: blackColor),
                        _dataCell(article.observations ?? '', textColor: blackColor),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: tealColor),
                      borderRadius: pw.BorderRadius.circular(5),
                      color: lightTealColor,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _totalLine('Total:', bon.montantTotal.toStringAsFixed(2), isBold: true, textColor: blackColor, valueColor: blackColor),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Préparé par',
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
                      pw.Text('(Signature)',
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: blackColor)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Transporteur',
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
                      pw.Text('(Signature)',
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: blackColor)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Réceptionné par',
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
                      pw.Text('(Signature)',
                          style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10, color: blackColor)),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              pw.Footer(
                margin: pw.EdgeInsets.only(top: 10),
                trailing: pw.Text(
                  'Document généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: tealColor),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bon_Transfert_${bon.reference}_${DateFormat('yyyyMMdd').format(bon.dateTransfert)}',
    );
  } catch (e) {
    print('Erreur lors de la génération du PDF: $e');
  }
}

// Helper functions for table cells
pw.Padding _headerCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
    ),
  );
}

pw.Padding _dataCell(String text, {PdfColor? textColor}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: textColor ?? PdfColors.black,
      ),
    ),
  );
}

pw.Row _totalLine(String label, String value, {
  bool isBold = false,
  bool isHighlighted = false,
  PdfColor? textColor,
  PdfColor? valueColor,
}) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? PdfColors.black,
        ),
      ),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: valueColor ?? PdfColors.black,
        ),
      ),
    ],
  );
}

  void _showBonDetails(BonTransfert bon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails du Bon de Transfert', style: TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Référence: ${bon.reference}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Entrepôt Source: ${bon.entrepotSource}'),
                SizedBox(height: 8),
                Text('Entrepôt Destination: ${bon.entrepotDestination}'),
                SizedBox(height: 8),
                Text('Date: ${DateFormat('dd/MM/yyyy').format(bon.dateTransfert)}'),
                SizedBox(height: 8),
                Text('Statut: ${bon.statut}', style: TextStyle(
                  color: bon.statut == 'Terminé' ? Colors.green : 
                        bon.statut == 'Annulé' ? Colors.red : 
                        bon.statut == 'En cours' ? Colors.orange : Colors.grey,
                  fontWeight: FontWeight.bold,
                )),
                SizedBox(height: 16),
                Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...bon.articles.map((article) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${article.reference} - ${article.libelle}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Quantité: ${article.quantite.toStringAsFixed(2)}'),
                        if (article.prix != null) Text('Prix: ${article.prix!.toStringAsFixed(2)}'),
                        if (article.observations != null) Text('Observations: ${article.observations}'),
                        Divider(),
                      ],
                    ),
                  );
                }).toList(),
                if (bon.montantTotal > 0) 
                  Text('Total: ${bon.montantTotal.toStringAsFixed(2)}', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _editBon(BonTransfert bon) {
    // Implémentez la logique de modification ici
    // Vous pouvez naviguer vers une nouvelle page ou utiliser un dialogue
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité de modification à implémenter')),
    );
  }

  void _deleteBon(BonTransfert bon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer le bon de transfert ${bon.reference}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  widget.historiqueBons.remove(bon);
                  _filterBons();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bon de transfert supprimé avec succès')),
                );
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Bons de Transfert', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher...',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBons.isEmpty
                ? Center(
                    child: Text(
                      'Aucun bon de transfert trouvé',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBons.length,
                    itemBuilder: (context, index) {
                      final bon = _filteredBons[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          title: Text(bon.reference, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${bon.entrepotSource} → ${bon.entrepotDestination}'),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(bon.dateTransfert)} - ${bon.statut}',
                                style: TextStyle(
                                  color: bon.statut == 'Terminé' ? Colors.green : 
                                        bon.statut == 'Annulé' ? Colors.red : 
                                        bon.statut == 'En cours' ? Colors.orange : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.picture_as_pdf, color: Colors.teal),
                                onPressed: () => _generatePdf(bon),
                                tooltip: 'Générer PDF',
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editBon(bon),
                                tooltip: 'Modifier',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBon(bon),
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                          onTap: () => _showBonDetails(bon),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}