import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

class FactureItem {
  String nom;
  double quantite;
  double prixUnitaire;
  double tva;
  double get totalHT => quantite * prixUnitaire;
  double get montantTVA => totalHT * (tva / 100);
  double get totalTTC => totalHT + montantTVA;

  FactureItem({
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
    required this.tva,
  });
}

class FactureScreen extends StatefulWidget {
  @override
  _FactureScreenState createState() => _FactureScreenState();
}

class _FactureScreenState extends State<FactureScreen> {
  final TextEditingController _numeroFactureController = TextEditingController(text: 'FAC-${DateFormat('yyyy').format(DateTime.now())}-001');
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _adresseFacturationController = TextEditingController();
  final TextEditingController _adresseLivraisonController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController(text: '0');
  final TextEditingController _timbreController = TextEditingController(text: '1.0');

  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixUnitaireController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController(text: '20.0');

  DateTime _dateFacture = DateTime.now();
  String? _selectedClient;
  bool _isTTC = false;
  List<FactureItem> items = [];
  double _totalHT = 0.0;
  double _totalFacture = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;

  List<String> _clients = ['Client 1', 'Client 2'];
  List<Map<String, dynamic>> _listeArticles = [
    {'nom': 'Article 1', 'prixHT': 50.0, 'tva': 20.0},
    {'nom': 'Article 2', 'prixHT': 30.0, 'tva': 20.0},
    {'nom': 'Article 3', 'prixHT': 20.0, 'tva': 20.0},
  ];
  String? _selectedArticle;

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'dt', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tvaController.text = '20.0';
  }

  @override
  void dispose() {
    _numeroFactureController.dispose();
    _responsableController.dispose();
    _adresseFacturationController.dispose();
    _adresseLivraisonController.dispose();
    _remiseController.dispose();
    _timbreController.dispose();
    _quantiteController.dispose();
    _prixUnitaireController.dispose();
    _tvaController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedArticle == null ||
        _quantiteController.text.isEmpty ||
        _prixUnitaireController.text.isEmpty ||
        _tvaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() {
      items.add(
        FactureItem(
          nom: _selectedArticle!,
          quantite: double.tryParse(_quantiteController.text) ?? 0,
          prixUnitaire: double.tryParse(_prixUnitaireController.text) ?? 0,
          tva: double.tryParse(_tvaController.text) ?? 20.0,
        ),
      );

      _selectedArticle = null;
      _quantiteController.clear();
      _prixUnitaireController.clear();
      _tvaController.text = '20.0';
      _calculerTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      _calculerTotal();
    });
  }

  void _calculerTotal() {
    double sousTotal = items.fold(0.0, (sum, item) => sum + item.totalHT);
    double totalTVA = items.fold(0.0, (sum, item) => sum + item.montantTVA);

    double remise = double.tryParse(_remiseController.text) ?? 0.0;
    double timbre = double.tryParse(_timbreController.text) ?? 1.0;

    setState(() {
      _sousTotal = sousTotal;
      _totalTVA = totalTVA;
      _totalHT = sousTotal - remise;
      _totalFacture = sousTotal + totalTVA - remise + timbre;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFacture,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateFacture) {
      setState(() {
        _dateFacture = picked;
      });
    };
  }

  Future<void> _saveAndGeneratePdf() async {
    if (_selectedClient == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un client et ajouter des articles')),
      );
      return;
    }

    await _generatePdf();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Facture enregistrée et PDF généré avec succès')),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final timbre = double.tryParse(_timbreController.text) ?? 1.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'FACTURE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Facture N°: ${_numeroFactureController.text}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(_dateFacture)}'),
                      pw.Text('Responsable: ${_responsableController.text}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(_selectedClient ?? ""),
                      pw.Text('Adresse: ${_adresseFacturationController.text}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Détail des articles:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                headers: ['Article', 'Qté', 'Prix HT', 'TVA %', 'Montant HT', 'Montant TTC'],
                data: items.map((item) => [
                  item.nom,
                  item.quantite.toString(),
                  '${item.prixUnitaire.toStringAsFixed(2)} dt',
                  '${item.tva.toStringAsFixed(2)}%',
                  '${item.totalHT.toStringAsFixed(2)} dt',
                  '${item.totalTTC.toStringAsFixed(2)} dt',
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 300,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Sous-total HT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${_sousTotal.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TVA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${_totalTVA.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      if (double.parse(_remiseController.text) > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Remise:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('-${double.parse(_remiseController.text).toStringAsFixed(2)} dt'),
                          ],
                        ),
                      ],
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Timbre fiscal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${timbre.toStringAsFixed(2)} dt'),
                        ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total HT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('${_totalHT.toStringAsFixed(2)} dt'),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total TTC:', style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.blue800,
                            )),
                            pw.Text('${_totalFacture.toStringAsFixed(2)} dt', style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.blue800,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text('Conditions de paiement:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Paiement à réception de facture par virement bancaire', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 5),
                pw.Text('En cas de retard de paiement, pénalité de 3 fois le taux d\'intérêt légal', style: pw.TextStyle(fontSize: 10)),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/facture_${_numeroFactureController.text}.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);
    }

    void _navigateToHistorique() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoriqueFacturesScreen()),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Nouvelle Facture'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              onPressed: _navigateToHistorique,
              tooltip: 'Historique des factures',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFactureDetailsEditor(),
              SizedBox(height: 20),
              _buildItemEditor(),
              SizedBox(height: 20),
              _buildTable(),
              SizedBox(height: 20),
              _buildRemiseTimbre(),
              SizedBox(height: 20),
              _buildTotals(),
              SizedBox(height: 20),
              _buildSaveButton(),
            ],
          ),
        ),
      );
    }

    Widget _buildFactureDetailsEditor() {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numeroFactureController,
                      decoration: InputDecoration(
                        labelText: 'Numéro de facture',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateFacture)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _responsableController,
                decoration: InputDecoration(
                  labelText: 'Responsable de facturation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedClient,
                onChanged: (value) => setState(() => _selectedClient = value),
                items: _clients
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _adresseFacturationController,
                decoration: InputDecoration(
                  labelText: 'Adresse de facturation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _adresseLivraisonController,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      );
    }

   Widget _buildItemEditor() {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter un article',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedArticle,
            hint: const Text('Sélectionnez un article'),
            onChanged: _listeArticles.isNotEmpty
                ? (value) {
                    setState(() {
                      _selectedArticle = value;
                      if (value != null) {
                        final article = _listeArticles.firstWhere(
                          (a) => a['nom'] == value,
                          orElse: () => {'prixHT': 0.0, 'tva': 20.0},
                        );
                        _prixUnitaireController.text =
                            article['prixHT'].toString();
                        _tvaController.text = article['tva'].toString();
                      }
                    });
                  }
                : null,
            items: _listeArticles
                .map((a) => DropdownMenuItem<String>(
                      value: a['nom'],
                      child: Text(a['nom']),
                    ))
                .toList(),
            decoration: const InputDecoration(
              labelText: 'Article',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_basket),
            ),
            validator: (value) =>
                value == null ? 'Veuillez sélectionner un article' : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une quantité';
                    }
                    final numValue = double.tryParse(value);
                    if (numValue == null || numValue <= 0) {
                      return 'Quantité invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _prixUnitaireController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.euro),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prix';
                    }
                    final numValue = double.tryParse(value);
                    if (numValue == null || numValue < 0) {
                      return 'Prix invalide';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _tvaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TVA (%)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une TVA';
                    }
                    final numValue = double.tryParse(value);
                    if (numValue == null || numValue < 0) {
                      return 'TVA invalide';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                if (Form.of(context)?.validate() ?? false) {
                  _addItem();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
          ),
        ],
      ),
    ),
  );
}

    Widget _buildTable() {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails de la prestation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(0.5),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.teal),
                    children: [
                      _buildTableCell('Article', isHeader: true),
                      _buildTableCell('Quantité', isHeader: true),
                      _buildTableCell('Prix HT', isHeader: true),
                      _buildTableCell('TVA %', isHeader: true),
                      _buildTableCell('Total HT', isHeader: true),
                      _buildTableCell('', isHeader: true),
                    ],
                  ),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return TableRow(
                      children: [
                        _buildTableCell(item.nom),
                        _buildTableCell(item.quantite.toString()),
                        _buildTableCell('${item.prixUnitaire.toStringAsFixed(2)} dt'),
                        _buildTableCell('${item.tva.toStringAsFixed(2)}%'),
                        _buildTableCell('${item.totalHT.toStringAsFixed(2)} dt'),
                        TableCell(
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                            iconSize: 16,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTableCell(String text, {bool isHeader = false}) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHeader ? Colors.white : Colors.black,
          ),
          textAlign: isHeader ? TextAlign.center : TextAlign.left,
        ),
      );
    }

    Widget _buildRemiseTimbre() {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remise et Timbre',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _remiseController,
                      decoration: InputDecoration(
                        labelText: 'Remise (dt)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.discount),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculerTotal(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _timbreController,
                      decoration: InputDecoration(
                        labelText: 'Timbre fiscal (dt)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.soap),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculerTotal(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildTotals() {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Totaux',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildTotalRow('Sous-total HT:', _sousTotal),
              _buildTotalRow('TVA:', _totalTVA),
              if (double.parse(_remiseController.text) > 0)
                _buildTotalRow('Remise:', -double.parse(_remiseController.text)),
              _buildTotalRow('Timbre fiscal:', double.parse(_timbreController.text)),
              Divider(),
              _buildTotalRow('Total HT:', _totalHT, isBold: true),
              _buildTotalRow('Total TTC:', _totalFacture, isBold: true),
            ],
          ),
        ),
      );
    }

    Widget _buildTotalRow(String label, double value, {bool isBold = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
            Text('${value.toStringAsFixed(2)} dt', style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
          ],
        ),
      );
    }

    Widget _buildSaveButton() {
      return Center(
        child: ElevatedButton(
          onPressed: _saveAndGeneratePdf,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Enregistrer la facture', style: TextStyle(fontSize: 16)),
        ),
      );
    }
}

class HistoriqueFacturesScreen extends StatefulWidget {
  @override
  _HistoriqueFacturesScreenState createState() => _HistoriqueFacturesScreenState();
}

class _HistoriqueFacturesScreenState extends State<HistoriqueFacturesScreen> {
  List<Map<String, dynamic>> factures = [
    {
      'reference': 'FAC-2023-001',
      'client': 'Client 1',
      'date': '01/01/2023',
      'montant': 1200.50,
      'pdfPath': '/path/to/facture1.pdf',
      'articles': [
        {'nom': 'Produit A', 'quantite': 2, 'prixHT': 100.0, 'tva': 20.0},
        {'nom': 'Produit B', 'quantite': 1, 'prixHT': 150.0, 'tva': 20.0},
      ],
      'remarques': 'Paiement à 30 jours',
    },
    {
      'reference': 'FAC-2023-002',
      'client': 'Client 2',
      'date': '15/01/2023',
      'montant': 850.75,
      'pdfPath': '/path/to/facture2.pdf',
      'articles': [
        {'nom': 'Produit C', 'quantite': 3, 'prixHT': 75.0, 'tva': 10.0},
        {'nom': 'Produit D', 'quantite': 2, 'prixHT': 120.0, 'tva': 10.0},
      ],
      'remarques': 'Paiement comptant',
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredFactures = factures.where((facture) {
      final ref = facture['reference'].toString().toLowerCase();
      final client = facture['client'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return ref.contains(query) || client.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des factures'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher par référence ou client',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFactures.length,
              itemBuilder: (context, index) {
                final facture = filteredFactures[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Facture ${facture['reference']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${facture['client']}'),
                        Text('Date: ${facture['date']}'),
                        Text('Montant: ${facture['montant'].toStringAsFixed(2)} dt'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Colors.teal),
                          onPressed: () {
                            _showDetailsDialog(context, facture);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.teal),
                          onPressed: () {
                            _navigateToEditForm(context, facture);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.teal),
                          onPressed: () {
                            _genererPDFDetaille(facture);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.teal),
                          onPressed: () {
                            _confirmDelete(context, facture);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> facture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la facture ${facture['reference']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Référence:', facture['reference']),
              _buildDetailRow('Client:', facture['client']),
              _buildDetailRow('Date:', facture['date']),
              _buildDetailRow('Montant:', '${facture['montant'].toStringAsFixed(2)} dt'),
              SizedBox(height: 16),
              Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...facture['articles'].map<Widget>((article) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('- ${article['nom']} (x${article['quantite']}) - ${article['prixHT']} HT'),
              )).toList(),
              SizedBox(height: 16),
              Text('Remarques:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(facture['remarques'] ?? 'Aucune remarque'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  void _navigateToEditForm(BuildContext context, Map<String, dynamic> facture) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => FactureScreen(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Édition de la facture ${facture['reference']}')),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> facture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer la facture ${facture['reference']} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                factures.removeWhere((f) => f['reference'] == facture['reference']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Facture supprimée')),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _genererPDFDetaille(Map<String, dynamic> facture) async {
    try {
      final PdfColor tealColor = PdfColor.fromHex('#008080');
      final PdfColor greenColor = PdfColor.fromHex('#00A651');
      final PdfColor whiteColor = PdfColors.white;
      final PdfColor blackColor = PdfColors.black;
      final PdfColor lightTealColor = PdfColor.fromHex('#E0F2F1');

      double totalHT = 0;
      double totalTVA = 0;
      double totalTTC = 0;

      for (var article in facture['articles']) {
        double montantHT = article['prixHT'] * article['quantite'];
        double montantTVA = montantHT * (article['tva'] / 100);
        totalHT += montantHT;
        totalTVA += montantTVA;
      }
      totalTTC = totalHT + totalTVA;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      height: 80,
                      child: pw.Text('LOGO', style: pw.TextStyle(fontSize: 24, color: tealColor)),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Entreprise', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: tealColor)),
                        pw.SizedBox(height: 5),
                        pw.Text('Adresse: 123 Rue Principale, Ville'),
                        pw.Text('Tél: 0123456789'),
                        pw.Text('Email: contact@entreprise.com'),
                        pw.Text('SIRET: 12345678901234'),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: tealColor),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'FACTURE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: tealColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
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
                            pw.Text('DÉTAILS DE LA FACTURE',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: tealColor)),
                            pw.SizedBox(height: 10),
                            _pdfDetailRow('Référence:', facture['reference']),
                            _pdfDetailRow('Date:', facture['date']),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
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
                            pw.Text('CLIENT',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                    color: tealColor)),
                            pw.SizedBox(height: 10),
                            pw.Text(facture['client'],
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: blackColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Articles',
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
                        _pdfHeaderCell('Article'),
                        _pdfHeaderCell('Qté'),
                        _pdfHeaderCell('Prix HT'),
                        _pdfHeaderCell('TVA'),
                        _pdfHeaderCell('Total HT'),
                        _pdfHeaderCell('Total TTC'),
                      ],
                    ),
                    for (var article in facture['articles'])
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: tealColor, width: 1),
                          ),
                        ),
                        children: [
                          _pdfDataCell(article['nom']),
                          _pdfDataCell(article['quantite'].toString()),
                          _pdfDataCell('${article['prixHT'].toStringAsFixed(2)} dt'),
                          _pdfDataCell('${article['tva'].toStringAsFixed(0)}%'),
                          _pdfDataCell('${(article['prixHT'] * article['quantite']).toStringAsFixed(2)} dt'),
                          _pdfDataCell('${(article['prixHT'] * article['quantite'] * (1 + article['tva']/100)).toStringAsFixed(2)} dt'),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 20),
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
                          _pdfTotalLine('Sous-total HT:', totalHT),
                          _pdfTotalLine('TVA:', totalTVA),
                          pw.Divider(thickness: 1, color: tealColor),
                          _pdfTotalLine('Total HT:', totalHT, isBold: true),
                          _pdfTotalLine('Total TTC:', totalTTC, isBold: true, isHighlighted: true),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
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
                      pw.Text(facture['remarques'] ?? 'Paiement à 30 jours'),
                      pw.SizedBox(height: 10),
                      pw.Text('Remarques:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: tealColor)),
                      pw.SizedBox(height: 5),
                      pw.Text('Merci pour votre confiance.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Pour le client',
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
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Pour l\'entreprise',
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
                            style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final String filename = 'facture_${facture['reference']}.pdf';
      final file = await saveDocument(filename, pdf);
      if (file != null) {
        OpenFile.open(file.path);
      }
    } catch (e) {
      print('Erreur lors de la génération du PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération du PDF')),
      );
    }
  }

  pw.Widget _pdfHeaderCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _pdfDataCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(text),
    );
  }

  pw.Widget _pdfDetailRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 5),
        pw.Text(value),
      ],
    );
  }

  pw.Widget _pdfTotalLine(String label, double value, {bool isBold = false, bool isHighlighted = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
          pw.Text('${value.toStringAsFixed(2)} dt',
              style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) :
                     isHighlighted ? pw.TextStyle(color: PdfColors.green) : null),
        ],
      ),
    );
  }

  Future<File?> saveDocument(String name, pw.Document pdf) async {
    try {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Erreur lors de la sauvegarde du document: $e');
      return null;
    }
  }
}