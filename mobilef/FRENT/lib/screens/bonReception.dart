import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/fournisseur.dart';
import 'article.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import 'fournisseur/fournisseur.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Gestion des bons',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: BonDeReceptionScreen(),
    ),
  );
}

class BonDeReceptionScreen extends StatefulWidget {
  @override
  _BonDeReceptionScreenState createState() => _BonDeReceptionScreenState();
}

class _BonDeReceptionScreenState extends State<BonDeReceptionScreen> {
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController(
    text: 'RN${DateTime.now().year}${_generateReferenceNumber()}',
  );
  final TextEditingController _adresseFacturationController =
      TextEditingController();
  final TextEditingController _objetController = TextEditingController(
    text: 'Climatisation',
  );
  final TextEditingController _remiseController = TextEditingController(
    text: '0',
  );
  final TextEditingController _remisePourcentageController =
      TextEditingController(text: '0');
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _remarquesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedFournisseur;
  String? _selectedCategorie = 'Climatiseur';
  List<Map<String, dynamic>> _articles = [];
  double _sousTotal = 0.0;
  double _totalRemise = 0.0;
  double _totalTVA = 0.0;
  double _total = 0.0;
  bool _taxeIncluse = false;
  bool _utiliserAvenir = false;

  List<String> _fournisseurs = ['Fournisseur 1', 'Fournisseur 2'];
  List<String> _categories = [
    'Climatiseur',
    'Chauffage',
    'Réfrigération',
    'Plomberie',
    'Sanitaire',
    'Électricité',
    'Ventilation',
  ];

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
  final TextEditingController _descriptionController = TextEditingController();

  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'د.إ',
    decimalDigits: 2,
  );

  static String _generateReferenceNumber() {
    return '00001';
  }

  void _ajouterArticle(Map<String, dynamic> article) {
    setState(() {
      double prixHT = article['prixHT'];
      double tva = article['tva'];
      int quantite = article['quantite'];
      String description = article['description'] ?? '';
      double prixTTC = prixHT * (1 + tva / 100);

      _articles.add({
        'nom': article['nom'],
        'description': description,
        'quantite': quantite,
        'prixHT': prixHT,
        'tva': tva,
        'prixTTC': prixTTC,
        'montantHT': prixHT * quantite,
        'montantTVA': prixHT * quantite * (tva / 100),
        'montantTTC': prixTTC * quantite,
      });
      _calculerTotal();

      _selectedArticle = null;
      _prixController.clear();
      _quantiteController.clear();
      _tvaController.text = '20.0';
      _descriptionController.clear();
    });
  }

  void _calculerTotal() {
    double sousTotal = _articles.fold(
      0.0,
      (sum, article) =>
          sum + (_taxeIncluse ? article['montantTTC'] : article['montantHT']),
    );

    double remise = double.tryParse(_remiseController.text) ?? 0.0;
    double remisePourcentage =
        double.tryParse(_remisePourcentageController.text) ?? 0.0;

    double totalRemise =
        remisePourcentage > 0 ? sousTotal * (remisePourcentage / 100) : remise;

    setState(() {
      _sousTotal = sousTotal;
      _totalRemise = totalRemise;
      _totalTVA = _articles.fold(
        0.0,
        (sum, article) => sum + article['montantTVA'],
      );
      _total = sousTotal - totalRemise;
    });
  }

  void _supprimerArticle(int index) {
    setState(() {
      _articles.removeAt(index);
      _calculerTotal();
    });
  }

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

  void _enregistrerReception() {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bon de réception enregistré avec succès"),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un article"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _genererPDF() async {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      final pdf = pw.Document();

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
                    'BON DE RECEPTION',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        ),
                        pw.Text('Catégorie: $_selectedCategorie'),
                        pw.Text('Objet: ${_objetController.text}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Référence: ${_referenceController.text}'),
                        pw.Text('Fournisseur: ${_selectedFournisseur ?? ""}'),
                        pw.Text(
                          'Adresse de facturation: ${_adresseFacturationController.text}',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Articles:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Article'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Description'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Qté'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('P.U.'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('TVA'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Prix'),
                        ),
                      ],
                    ),
                    for (var article in _articles)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(article['nom']),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(article['description'] ?? ''),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(article['quantite'].toString()),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${article['prixHT'].toStringAsFixed(2)} د.إ',
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text('${article['tva']}%'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${(_taxeIncluse ? article['montantTTC'] : article['montantHT']).toStringAsFixed(2)} د.إ',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Sous-total: ${_sousTotal.toStringAsFixed(2)} د.إ',
                        ),
                        pw.Text(
                          'Remise: ${_totalRemise.toStringAsFixed(2)} د.إ',
                        ),
                        if (_taxeIncluse)
                          pw.Text(
                            'Dont TVA: ${_totalTVA.toStringAsFixed(2)} د.إ',
                          ),
                        pw.Divider(),
                        pw.Text(
                          'Total: ${_total.toStringAsFixed(2)} د.إ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Conditions générales: ${_conditionsController.text}'),
                pw.SizedBox(height: 10),
                pw.Text('Remarques: ${_remarquesController.text}'),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
        "${output.path}/reception_${_referenceController.text}.pdf",
      );
      await file.writeAsBytes(await pdf.save());

      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF généré avec succès"),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un article"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _ajouterFournisseur(Fournisseur fournisseur) {
    setState(() {
      _fournisseurs.add(fournisseur.nomFournisseur);
      _selectedFournisseur = fournisseur.nom;
    });
  }

  Future<void> _navigateToAddFournisseurScreen(BuildContext context) async {
    final Fournisseur? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurScreen(fournisseurData: {}),
      ),
    );

    if (result != null) {
      _ajouterFournisseur(result);
    }
  }

  Future<void> _navigateToAddArticleScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ArticleFormScreen(
              onSave: (article) async {
                // Handle saving the article here
                print('Saving article: $article');
                // You can return something if needed
                return;
              },
            ),
      ),
    );

    // Handle the result if needed
    print('Result from ArticleFormScreen: $result');
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bon de Réception'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoriqueBonsScreen()),
              );
            },
            tooltip: 'Historique des bons',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Informations Générales'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      if (isSmallScreen) ...[
                        _buildDateField(context),
                        SizedBox(height: 12),
                        _buildCategoryDropdown(),
                        SizedBox(height: 12),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildDateField(context)),
                            SizedBox(width: 12),
                            Expanded(child: _buildCategoryDropdown()),
                          ],
                        ),
                      ],
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _objetController,
                        decoration: InputDecoration(
                          labelText: 'Objet',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subject),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          labelText: 'Numéro de référence',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Fournisseur'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                                    child: Text(f),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Fournisseur',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator:
                            (value) => value == null ? 'Champ requis' : null,
                      ),
                      SizedBox(height: 8),
                      TextButton.icon(
                        onPressed:
                            () => _navigateToAddFournisseurScreen(context),
                        icon: Icon(Icons.add_business),
                        label: Text(
                          'Ajouter un nouveau fournisseur',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _adresseFacturationController,
                        decoration: InputDecoration(
                          labelText: 'Adresse de facturation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Articles'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                                    child: Text(article['nom']),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Article',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _navigateToAddArticleScreen(context),
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text(
                          'Ajouter un nouvel article',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12),
                      if (isSmallScreen) ...[
                        _buildQuantityField(),
                        SizedBox(height: 12),
                        _buildPriceField(),
                        SizedBox(height: 12),
                        _buildTvaField(),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildQuantityField()),
                            SizedBox(width: 12),
                            Expanded(child: _buildPriceField()),
                            SizedBox(width: 12),
                            Expanded(child: _buildTvaField()),
                          ],
                        ),
                      ],
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedArticle != null &&
                                _quantiteController.text.isNotEmpty &&
                                _prixController.text.isNotEmpty &&
                                _tvaController.text.isNotEmpty) {
                              _ajouterArticle({
                                'nom': _selectedArticle!,
                                'description': _descriptionController.text,
                                'quantite': int.parse(_quantiteController.text),
                                'prixHT': double.parse(_prixController.text),
                                'tva': double.parse(_tvaController.text),
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Veuillez remplir tous les champs obligatoires",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Ajouter l\'article'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_articles.isNotEmpty) ...[
                _buildSectionHeader('Liste des articles'),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        headingRowColor:
                            MaterialStateProperty.resolveWith<Color?>((
                              Set<MaterialState> states,
                            ) {
                              return Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1);
                            }),
                        columns: [
                          DataColumn(
                            label: Text(
                              'Article',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          DataColumn(
                            label: Text('Qté', style: TextStyle(fontSize: 14)),
                          ),
                          DataColumn(
                            label: Text('P.U.', style: TextStyle(fontSize: 14)),
                          ),
                          DataColumn(
                            label: Text('TVA', style: TextStyle(fontSize: 14)),
                          ),
                          DataColumn(
                            label: Text('Prix', style: TextStyle(fontSize: 14)),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          _articles.length,
                          (index) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _articles[index]['nom'],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _articles[index]['quantite'].toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${_articles[index]['prixHT'].toStringAsFixed(2)} د.إ',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${_articles[index]['tva']}%',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${(_taxeIncluse ? _articles[index]['montantTTC'] : _articles[index]['montantHT']).toStringAsFixed(2)} د.إ',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () => _supprimerArticle(index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              _buildSectionHeader('Remise'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      if (isSmallScreen) ...[
                        _buildRemiseField(),
                        SizedBox(height: 12),
                        _buildRemisePourcentageField(),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildRemiseField()),
                            SizedBox(width: 12),
                            Expanded(child: _buildRemisePourcentageField()),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Totaux'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildTotalRow('Sous-total', _sousTotal),
                      _buildTotalRow('Remise', _totalRemise),
                      if (_taxeIncluse) _buildTotalRow('Dont TVA', _totalTVA),
                      Divider(thickness: 1),
                      _buildTotalRow('Total', _total, isBold: true),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Conditions et Remarques'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _conditionsController,
                        decoration: InputDecoration(
                          labelText: 'Conditions générales',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.gavel),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _remarquesController,
                        decoration: InputDecoration(
                          labelText: 'Remarques',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              _buildActionButtons(isSmallScreen),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategorie,
      onChanged: (value) => setState(() => _selectedCategorie = value),
      items:
          _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      validator: (value) => value == null ? 'Champ requis' : null,
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantiteController,
      decoration: InputDecoration(
        labelText: 'Quantité',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.format_list_numbered),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Champ requis';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Quantité invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _prixController,
      decoration: InputDecoration(
        labelText: 'Prix unitaire',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Champ requis';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Prix invalide';
        }
        return null;
      },
    );
  }

  Widget _buildTvaField() {
    return TextFormField(
      controller: _tvaController,
      decoration: InputDecoration(
        labelText: 'TVA (%)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.percent),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Champ requis';
        }
        if (double.tryParse(value) == null || double.parse(value) < 0) {
          return 'TVA invalide';
        }
        return null;
      },
    );
  }

  Widget _buildRemiseField() {
    return TextFormField(
      controller: _remiseController,
      decoration: InputDecoration(
        labelText: 'Montant de remise',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.money_off),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isNotEmpty && double.tryParse(value) != null) {
          _remisePourcentageController.text = '0';
        }
        _calculerTotal();
      },
    );
  }

  Widget _buildRemisePourcentageField() {
    return TextFormField(
      controller: _remisePourcentageController,
      decoration: InputDecoration(
        labelText: 'Pourcentage de remise',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.percent),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isNotEmpty && double.tryParse(value) != null) {
          _remiseController.text = '0';
        }
        _calculerTotal();
      },
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _enregistrerReception();
                }
              },
              child: Text('Enregistrer'),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _genererPDF,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Générer PDF'),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Annuler'),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _enregistrerReception();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Enregistrer'),
          ),
          ElevatedButton(
            onPressed: _genererPDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Générer PDF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Annuler'),
          ),
        ],
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} د.إ',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}




class HistoriqueBonsScreen extends StatefulWidget {
  @override
  _HistoriqueBonsScreenState createState() => _HistoriqueBonsScreenState();
}

class _HistoriqueBonsScreenState extends State<HistoriqueBonsScreen> {
  List<Map<String, dynamic>> _bons = [];
  List<Map<String, dynamic>> _filteredBons = [];
  TextEditingController _searchController = TextEditingController();
  String _sortColumn = 'date';
  bool _sortAscending = false;
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'د.إ', decimalDigits: 2);
  String _selectedCategory = 'Tous';
  String _selectedPeriod = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadBons();
    _searchController.addListener(_filterBons);
    _sortBons();
  }

  void _loadBons() {
    _bons = [
      {
        'id': '1',
        'reference': 'RN20230001',
        'date': '15/06/2023',
        'fournisseur': 'Fournisseur 1',
        'categorie': 'Climatiseur',
        'objet': 'Achat de fournitures',
        'articles': [
          {'nom': 'Article 1', 'quantite': 3, 'prixHT': 100.0, 'tva': 20.0},
          {'nom': 'Article 2', 'quantite': 2, 'prixHT': 75.0, 'tva': 20.0}
        ],
        'adresseFacturation': '123 Rue Principale, Ville',
        'remise': 50.0,
        'sousTotal': 450.0,
        'totalTVA': 90.0,
        'total': 490.0,
        'conditions': 'Paiement sous 30 jours',
        'remarques': 'Livraison prioritaire',
        'responsable': 'Jean Dupont',
      },
      {
        'id': '2',
        'reference': 'RN20230002',
        'date': '20/06/2023',
        'fournisseur': 'Fournisseur 2',
        'categorie': 'Chauffage',
        'objet': 'Équipement informatique',
        'articles': [
          {'nom': 'Article 3', 'quantite': 1, 'prixHT': 750.0, 'tva': 20.0}
        ],
        'adresseFacturation': '456 Avenue Centrale, Ville',
        'remise': 0.0,
        'sousTotal': 750.0,
        'totalTVA': 150.0,
        'total': 900.0,
        'conditions': 'Paiement à la livraison',
        'remarques': '',
        'responsable': 'Marie Leblanc',
      },
      {
        'id': '3',
        'reference': 'RN20230003',
        'date': '05/07/2023',
        'fournisseur': 'Fournisseur 3',
        'categorie': 'Réfrigération',
        'objet': 'Maintenance annuelle',
        'articles': [
          {'nom': 'Service 1', 'quantite': 1, 'prixHT': 1200.0, 'tva': 10.0}
        ],
        'adresseFacturation': '789 Rue du Commerce, Ville',
        'remise': 100.0,
        'sousTotal': 1200.0,
        'totalTVA': 120.0,
        'total': 1220.0,
        'conditions': 'Contrat annuel',
        'remarques': 'Renouvellement automatique',
        'responsable': 'Paul Martin',
      },
    ];
    _filteredBons = List.from(_bons);
  }

  void _filterBons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBons = _bons.where((bon) {
        // Filtre par recherche
        final matchesSearch = query.isEmpty ||
            bon['reference'].toLowerCase().contains(query) ||
            bon['fournisseur'].toLowerCase().contains(query) ||
            bon['objet'].toLowerCase().contains(query) ||
            bon['categorie'].toLowerCase().contains(query);
        
        // Filtre par catégorie
        final matchesCategory = _selectedCategory == 'Tous' || 
            bon['categorie'] == _selectedCategory;
        
        // Filtre par période (simplifié pour l'exemple)
        final matchesPeriod = _selectedPeriod == 'Tous' || true;
        
        return matchesSearch && matchesCategory && matchesPeriod;
      }).toList();
      _sortBons();
    });
  }

  void _sortBons() {
    setState(() {
      _filteredBons.sort((a, b) {
        var aValue = a[_sortColumn];
        var bValue = b[_sortColumn];
        
        if (_sortColumn == 'date') {
          final dateFormat = DateFormat('dd/MM/yyyy');
          try {
            aValue = dateFormat.parse(a[_sortColumn] as String);
            bValue = dateFormat.parse(b[_sortColumn] as String);
          } catch (e) {}
        } else if (_sortColumn == 'total') {
          aValue = a[_sortColumn] is num ? a[_sortColumn] : 0.0;
          bValue = b[_sortColumn] is num ? b[_sortColumn] : 0.0;
        }
        
        int comparison;
        if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }
        
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _onSortColumn(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = column != 'date';
      }
      _sortBons();
    });
  }

  void _deleteBon(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce bon de réception ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _bons.removeWhere((bon) => bon['id'] == id);
                _filterBons();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Bon supprimé avec succès"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _modifyBon(Map<String, dynamic> bon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Redirection vers l'écran de modification pour le bon ${bon['reference']}"),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
    ));
  }

  void _showBonDetails(Map<String, dynamic> bon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Détails du bon',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailRow('Référence', bon['reference']),
              _buildDetailRow('Date', bon['date']),
              _buildDetailRow('Fournisseur', bon['fournisseur']),
              _buildDetailRow('Catégorie', bon['categorie']),
              _buildDetailRow('Objet', bon['objet']),
              SizedBox(height: 16),
              Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...bon['articles'].map<Widget>((article) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article['nom'], style: TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qté: ${article['quantite']}'),
                        Text('Prix: ${article['prixHT'].toStringAsFixed(2)} د.إ'),
                        Text('TVA: ${article['tva']}%'),
                      ],
                    ),
                  ],
                ),
              )).toList(),
              SizedBox(height: 16),
              _buildDetailRow('Sous-total', currencyFormat.format(bon['sousTotal'])),
              _buildDetailRow('Remise', currencyFormat.format(bon['remise'])),
              _buildDetailRow('TVA', currencyFormat.format(bon['totalTVA'])),
              Divider(),
              _buildDetailRow('Total', currencyFormat.format(bon['total']), isBold: true),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _modifyBon(bon);
                    },
                    icon: Icon(Icons.edit, size: 20),
                    label: Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _exportToPDF(bon);
                    },
                    icon: Icon(Icons.picture_as_pdf, size: 20),
                    label: Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteBon(bon['id']);
                    },
                    icon: Icon(Icons.delete, size: 20),
                    label: Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(Map<String, dynamic> bon) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('BON DE RECEPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Date: ${bon['date']}'),
                    pw.Text('Catégorie: ${bon['categorie']}'),
                    pw.Text('Objet: ${bon['objet']}'),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Référence: ${bon['reference']}'),
                    pw.Text('Fournisseur: ${bon['fournisseur']}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Articles:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Article')),
                    pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Qté')),
                    pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('P.U.')),
                    pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Total')),
                  ],
                ),
                for (var article in bon['articles'])
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(article['nom'])),
                      pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(article['quantite'].toString())),
                      pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${article['prixHT'].toStringAsFixed(2)} د.إ')),
                      pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${(article['prixHT'] * article['quantite']).toStringAsFixed(2)} د.إ')),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Sous-total: ${bon['sousTotal'].toStringAsFixed(2)} د.إ'),
                    pw.Text('Remise: ${bon['remise'].toStringAsFixed(2)} د.إ'),
                    pw.Text('TVA: ${bon['totalTVA'].toStringAsFixed(2)} د.إ'),
                    pw.Divider(),
                    pw.Text('Total: ${bon['total'].toStringAsFixed(2)} د.إ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Conditions: ${bon['conditions'] ?? ""}'),
            pw.SizedBox(height: 10),
            pw.Text('Remarques: ${bon['remarques'] ?? ""}'),
          ],
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/reception_${bon['reference']}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF généré avec succès"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des bons'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => _buildFilterOptions(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un bon...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBons();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: _filteredBons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun bon trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBons.length,
                    itemBuilder: (context, index) {
                      final bon = _filteredBons[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showBonDetails(bon),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bon['reference'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                    Text(
                                      bon['date'],
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  bon['fournisseur'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  bon['objet'],
                                  style: TextStyle(color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      label: Text(bon['categorie']),
                                      backgroundColor: Colors.teal.shade50,
                                      labelStyle: TextStyle(color: Colors.teal.shade800),
                                    ),
                                    Text(
                                      currencyFormat.format(bon['total']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildFilterOptions() {
    final categories = ['Tous', 'Climatiseur', 'Chauffage', 'Réfrigération', 'Plomberie', 'Sanitaire', 'Électricité'];
    final periods = ['Tous', '7 derniers jours', '30 derniers jours', '3 derniers mois'];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtrer par', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Catégories:', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : 'Tous';
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 16),
              Text('Période:', style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: periods.map((period) => FilterChip(
                  label: Text(period),
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPeriod = selected ? period : 'Tous';
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _filterBons();
                      Navigator.pop(context);
                    },
                    child: Text('Appliquer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}