import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';

import '../models/fournisseur.dart';
import '../models/Client.dart';
import '../models/article.dart';

import '../services/client_service.dart';
import '../services/article_service.dart';
import 'article.dart';
import 'fournisseur/fournisseur.dart';

class FactureScreen1 extends StatefulWidget {
  @override
  _FactureScreenState createState() => _FactureScreenState();
}

class _FactureScreenState extends State<FactureScreen1> {
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _adresseFacturationController =
      TextEditingController();
  final TextEditingController _remiseController = TextEditingController(
    text: '0',
  );
  final TextEditingController _timbreController = TextEditingController(
    text: '1.0',
  );
  @override
  void initState() {
    super.initState();
    loadClients();
  }

  DateTime _selectedDate = DateTime.now();
  Client? _selectedClient;
  bool _isTTC = false;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalFacture = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;
  List<Client> _clients = [];
  List<Article> _listeArticles = [];
  Future<void> loadClients() async {
    try {
      List<Client> clients = await ClientService.fetchClients();
      print('Clients in facture screen: $clients');
      final articleService = ArticleService(); // ✅ Création de l'instance
      final listeArticles = await articleService.fetchAllArticles(); //

      setState(() {
        _clients = clients;
        _listeArticles = listeArticles;
      });
    } catch (e) {
      print('Error loading clients: $e');
      // Optionally handle error or show a message
    }
  }
  // Liste de clients existants

  // Liste des articles existants avec les prix HT par défaut

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
    double timbre = double.tryParse(_timbreController.text) ?? 1.0;

    setState(() {
      _sousTotal = sousTotal;
      _totalTVA = totalTVA;
      _totalHT = sousTotal - remise; // Total HT avec remise
      _totalFacture =
          sousTotal +
          totalTVA -
          remise +
          timbre; // Total TTC avec remise et timbre
    });
  }

  // Supprimer un article de la liste
  void _supprimerArticle(int index) {
    setState(() {
      _articles.removeAt(index);
      _calculerTotal();
    });
  }

  // Sélection de la date de facturation
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

  // Enregistrer la facture et générer le PDF
  Future<void> _enregistrerFacture() async {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      await _genererPDF();
      final String reference = _referenceController.text;
      final String responsable = _responsableController.text;
      final String adresseFacturation = _adresseFacturationController.text;
      final String client = _selectedClient?.id ?? '';
      final List<Map<String, dynamic>> articles =
          _articles.map((article) {
            return {
              'nom': article['nom'],
              'quantite': article['quantite'],
              'prixHT': article['prixHT'],
              'tva': article['tva'],
            };
          }).toList();

      final double remise = double.tryParse(_remiseController.text) ?? 0.0;
      final double timbre = double.tryParse(_timbreController.text) ?? 0.0;

      // Create the invoice data
      final Map<String, dynamic> invoiceData = {
        'reference': reference,
        'responsable': responsable,
        'adresseFacturation': adresseFacturation,
        'idCL': client,
        'idP': articles,
        'remise': remise,
        'timbre': timbre,
        'type': "Achat",
        // Add other necessary fields here
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Facture enregistrée et PDF généré avec succès"),
          backgroundColor: Colors.green,
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

  // Générer un PDF professionnel
  Future<void> _genererPDF() async {
    final pdf = pw.Document();
    final timbre = double.tryParse(_timbreController.text) ?? 1.0;

    // Ajout du logo (vous pouvez remplacer par votre propre image)
    final logo = pw.MemoryImage(
      (await rootBundle.load('images/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête avec logo et informations de l'entreprise
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ENTREPRISE XYZ',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Adresse: Rue dela nouvelle Delhi , Belvédére Tunis',
                      ),
                      pw.Text('Tél: 9230991'),
                      pw.Text('Email: contact@esprit-climatique.tn'),
                      pw.Text('Matricule fiscale: 1883626X/A/M/000'),
                    ],
                  ),
                  pw.SizedBox(width: 80, height: 80, child: pw.Image(logo)),
                ],
              ),

              pw.SizedBox(height: 20),

              // Titre FACTURE
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

              // Informations facture et client
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Facture N°: ${_referenceController.text}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      ),
                      pw.Text('Responsable: ${_responsableController.text}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Client:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(_selectedClient?.fullName ?? ""),
                      pw.Text('Adresse: ${_adresseFacturationController.text}'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Tableau des articles
              pw.Text(
                'Détail des articles:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),

              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                headers: [
                  'Article',
                  'Qté',
                  'Prix HT',
                  'TVA %',
                  'Montant HT',
                  'Montant TTC',
                ],
                data:
                    _articles
                        .map(
                          (article) => [
                            article['nom'],
                            article['quantite'].toString(),
                            '${article['prixHT'].toStringAsFixed(2)} dt',
                            '${article['tva']}%',
                            '${article['montantHT'].toStringAsFixed(2)} dt',
                            '${article['montantTTC'].toStringAsFixed(2)} dt',
                          ],
                        )
                        .toList(),
              ),

              pw.SizedBox(height: 20),

              // Totaux
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 300,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Sous-total HT:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('${_sousTotal.toStringAsFixed(2)} '),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'TVA:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('${_totalTVA.toStringAsFixed(2)} '),
                        ],
                      ),
                      if (double.parse(_remiseController.text) > 0) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Remise:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '-${double.parse(_remiseController.text).toStringAsFixed(2)} ',
                            ),
                          ],
                        ),
                      ],
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Timbre fiscal:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('${timbre.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      pw.Divider(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total HT:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('${_totalHT.toStringAsFixed(2)} dt'),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total TTC:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.Text(
                            '${_totalFacture.toStringAsFixed(2)} €',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 16,
                              color: PdfColors.blue800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 30),

              // Mentions légales
              pw.Text(
                'Conditions de paiement:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Paiement à réception de facture par virement bancaire',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'IBAN: FR76 1234 5678 9123 4567 8910 234',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'En cas de retard de paiement, pénalité de 3 fois le taux d\'intérêt légal',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Article L. 441-6 du code de commerce - Indemnité forfaitaire pour frais de recouvrement: 40dt',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    // Enregistrer le PDF
    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/facture_${_referenceController.text}_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    // Ouvrir le PDF
    OpenFile.open(file.path);
  }

  // Fonction pour ajouter un client
  void _ajouterClient(Fournisseur client) {
    setState(() {
      //  _clients.add(client.nomFournisseur);
      // _selectedClient = client;
    });
  }

  // Fonction pour naviguer vers l'écran d'ajout d'article
  Future<void> _navigateToAddArticleScreen(BuildContext context) async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ArticleFormScreen(
              onSave: (article) async {
                print('Saving article: $article');
                return;
              },
            ),
      ),
    );

    if (result != null) {
      _ajouterArticle(result);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facture'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoriqueFactures()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations Générales
              _buildSectionHeader('Informations Générales'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
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
                                      value!.isEmpty ? 'Champ requis' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date de facturation',
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _responsableController,
                        decoration: InputDecoration(
                          labelText: 'Responsable de facturation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adresseFacturationController,
                        decoration: InputDecoration(
                          labelText: 'Adresse de facturation',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Section Client
              _buildSectionHeader('Client'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<Client>(
                        value: _selectedClient,
                        onChanged:
                            (value) => setState(() => _selectedClient = value),
                        items:
                            _clients
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.fullName),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un client',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator:
                            (value) => value == null ? 'Champ requis' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // Section Articles
              _buildSectionHeader('Articles'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Afficher les prix en TTC'),
                              value: _isTTC,
                              onChanged:
                                  (value) => setState(() => _isTTC = value),
                              activeColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedArticle,
                        onChanged: (value) {
                          setState(() {
                            _selectedArticle = value;
                            var article = _listeArticles.firstWhere(
                              (article) => article.nomArticle == value,
                            );
                            _prixController.text = article.prixAchat.toString();
                          });
                        },
                        items:
                            _listeArticles
                                .map(
                                  (article) => DropdownMenuItem<String>(
                                    value: article.nomArticle,
                                    child: Text(article.nomArticle),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un article',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _navigateToAddArticleScreen(context),
                        icon: Icon(Icons.add_shopping_cart),
                        label: const Text('Ajouter un nouvel article'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteController,
                              decoration: InputDecoration(
                                labelText: 'Quantité',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.format_list_numbered),
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
                      const SizedBox(height: 16),
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Veuillez remplir tous les champs",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Ajouter l\'article'),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Liste des articles ajoutés
              if (_articles.isNotEmpty) ...[
                _buildSectionHeader('Liste des articles ajoutés'),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        for (var i = 0; i < _articles.length; i++)
                          ListTile(
                            title: Text(_articles[i]['nom']),
                            subtitle: Text(
                              'Quantité: ${_articles[i]['quantite']} - Prix HT: ${currencyFormat.format(_articles[i]['prixHT'])} - TVA: ${_articles[i]['tva']}%',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _supprimerArticle(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Section Remise et Timbre
              _buildSectionHeader('Remise et Timbre'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _remiseController,
                        decoration: InputDecoration(
                          labelText: 'Remise ()',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.discount),
                        ),
                        keyboardType: TextInputType.number,
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
                        onChanged: (value) => _calculerTotal(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timbreController,
                        decoration: InputDecoration(
                          labelText: 'Timbre fiscal (dt)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.soap),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Champ requis';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onChanged: (value) => _calculerTotal(),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Totaux
              _buildSectionHeader('Totaux'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sous-total HT:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(currencyFormat.format(_sousTotal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TVA:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(currencyFormat.format(_totalTVA)),
                        ],
                      ),
                      if (double.parse(_remiseController.text) > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remise:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '-${currencyFormat.format(double.parse(_remiseController.text))}',
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Timbre fiscal:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormat.format(
                              double.parse(_timbreController.text),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total HT:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(currencyFormat.format(_totalHT)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total TTC:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(currencyFormat.format(_totalFacture)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton d'enregistrement
              Center(
                child: ElevatedButton(
                  onPressed: _enregistrerFacture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer la facture',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour créer un en-tête de section
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}

class HistoriqueFactures extends StatefulWidget {
  @override
  _HistoriqueFacturesState createState() => _HistoriqueFacturesState();
}

class _HistoriqueFacturesState extends State<HistoriqueFactures> {
  List<Map<String, dynamic>> _factures = [
    {
      'reference': 'FAC-2023-001',
      'client': 'Client 1',
      'dateEmission': '15/01/2023',
      'dateEcheance': '15/02/2023',
      'statut': 'Payée',
      'total': 150.0,
      'totalHT': 125.0,
      'tva': 25.0,
      'tauxTVA': 20,
      'modePaiement': 'Virement bancaire',
      'adresseFacturation': '123 Rue du Commerce, 75001 Paris',
      'commentaire': 'Paiement reçu le 12/02/2023',
      'articles': [
        {
          'nom': 'Article 1',
          'reference': 'ART001',
          'quantite': 2,
          'prixUnitaireHT': 50.0,
          'tauxTVA': 20,
          'totalHT': 100.0,
          'totalTTC': 120.0,
        },
      ],
    },
    {
      'reference': 'FAC-2023-002',
      'client': 'Client 2',
      'dateEmission': '20/01/2023',
      'dateEcheance': '20/02/2023',
      'statut': 'En attente',
      'total': 250.0,
      'totalHT': 208.33,
      'tva': 41.67,
      'tauxTVA': 20,
      'modePaiement': 'Carte bancaire',
      'adresseFacturation': '456 Avenue du Marché, 69002 Lyon',
      'commentaire': 'Relance envoyée le 15/02/2023',
      'articles': [
        {
          'nom': 'Article 2',
          'reference': 'ART002',
          'quantite': 3,
          'prixUnitaireHT': 30.0,
          'tauxTVA': 20,
          'totalHT': 90.0,
          'totalTTC': 108.0,
        },
        {
          'nom': 'Article 3',
          'reference': 'ART003',
          'quantite': 2,
          'prixUnitaireHT': 59.17,
          'tauxTVA': 20,
          'totalHT': 118.33,
          'totalTTC': 142.0,
        },
      ],
    },
  ];

  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFactures = [];

  @override
  void initState() {
    super.initState();
    _filteredFactures = _factures;
  }

  void _filterFactures(String query) {
    setState(() {
      _filteredFactures =
          _factures.where((facture) {
            return facture['reference'].toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                facture['client'].toLowerCase().contains(query.toLowerCase()) ||
                facture['statut'].toLowerCase().contains(query.toLowerCase());
          }).toList();
    });
  }

  void _deleteFacture(int index) {
    setState(() {
      final factureToDelete = _filteredFactures[index];
      _factures.removeWhere(
        (f) => f['reference'] == factureToDelete['reference'],
      );
      _filterFactures(_searchController.text);
    });
  }

  Future<void> _generatePdf(Map<String, dynamic> facture) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 2,
    );

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
                  'Facture ${facture['reference']}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Informations de base
              _buildPdfDetailRow('Client:', facture['client']),
              _buildPdfDetailRow('Date d\'émission:', facture['dateEmission']),
              _buildPdfDetailRow('Date d\'échéance:', facture['dateEcheance']),
              _buildPdfDetailRow('Statut:', facture['statut']),
              _buildPdfDetailRow('Mode de paiement:', facture['modePaiement']),
              pw.SizedBox(height: 20),

              // Adresse de facturation
              pw.Text(
                'Adresse de facturation:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(facture['adresseFacturation']),
              pw.SizedBox(height: 20),

              // Tableau des articles
              pw.Text(
                'Articles:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              pw.Table.fromTextArray(
                context: context,
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#6aa84f'),
                ),
                headerStyle: pw.TextStyle(color: PdfColors.white),
                headers: [
                  'Article',
                  'Référence',
                  'Qté',
                  'Prix HT',
                  'TVA %',
                  'Total HT',
                  'Total TTC',
                ],
                data:
                    facture['articles']
                        .map(
                          (article) => [
                            article['nom'],
                            article['reference'],
                            article['quantite'].toString(),
                            currencyFormat.format(article['prixUnitaireHT']),
                            '${article['tauxTVA']}%',
                            currencyFormat.format(article['totalHT']),
                            currencyFormat.format(article['totalTTC']),
                          ],
                        )
                        .toList(),
              ),

              pw.SizedBox(height: 20),

              // Totaux
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfTotalRow(
                      'Sous-total HT:',
                      facture['totalHT'],
                      currencyFormat,
                    ),
                    _buildPdfTotalRow(
                      'TVA (${facture['tauxTVA']}%):',
                      facture['tva'],
                      currencyFormat,
                    ),
                    pw.Divider(),
                    _buildPdfTotalRow(
                      'Total TTC:',
                      facture['total'],
                      currencyFormat,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Commentaire
              if (facture['commentaire'] != null &&
                  facture['commentaire'].isNotEmpty) ...[
                pw.Text(
                  'Commentaire:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(facture['commentaire']),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    double value,
    NumberFormat format, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
          pw.Text(
            format.format(value),
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique Factures',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
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
                labelText: 'Rechercher',
                hintText: 'Réf., client, statut',
                prefixIcon: Icon(Icons.search, size: 20),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
              ),
              onChanged: _filterFactures,
            ),
          ),
          Expanded(
            child:
                _filteredFactures.isEmpty
                    ? Center(child: Text('Aucune facture trouvée'))
                    : ListView.builder(
                      itemCount: _filteredFactures.length,
                      itemBuilder: (context, index) {
                        final facture = _filteredFactures[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: InkWell(
                            onTap: () => _showDetailsDialog(context, facture),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        facture['reference'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 14 : 16,
                                        ),
                                      ),
                                      _getStatusBadge(facture['statut']),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    facture['client'],
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${facture['dateEmission']}',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 12 : 13,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'fr_FR',
                                          symbol: '€',
                                        ).format(facture['total']),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 13 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isSmallScreen) SizedBox(height: 4),
                                  if (!isSmallScreen)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            // Implémenter la modification
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _confirmDelete(context, index);
                                          },
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
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, size: 24),
        onPressed: () {
          // Naviguer vers la page de création de facture
        },
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'payée':
        color = Colors.green;
        break;
      case 'en attente':
        color = Colors.orange;
        break;
      case 'annulée':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmation', style: TextStyle(fontSize: 18)),
          content: Text(
            'Supprimer cette facture ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                _deleteFacture(index);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Facture supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> facture) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 2,
    );
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Détails de la facture',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),

                // Informations de base
                _buildDetailRow('Référence:', facture['reference']),
                _buildDetailRow('Client:', facture['client']),
                _buildDetailRow('Date d\'émission:', facture['dateEmission']),
                _buildDetailRow('Date d\'échéance:', facture['dateEcheance']),
                _buildDetailRow('Statut:', facture['statut'], isStatus: true),
                _buildDetailRow('Mode de paiement:', facture['modePaiement']),
                SizedBox(height: 15),

                // Adresse de facturation
                Text(
                  'Adresse de facturation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(facture['adresseFacturation']),
                SizedBox(height: 15),

                // Articles
                Text(
                  'Articles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Tableau des articles (simplifié pour mobile)
                if (isSmallScreen) ...[
                  for (var article in facture['articles'])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${article['nom']} (x${article['quantite']})'),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Prix unitaire: ${currencyFormat.format(article['prixUnitaireHT'])} HT',
                            ),
                            Text(
                              'Total: ${currencyFormat.format(article['totalTTC'])} TTC',
                            ),
                          ],
                        ),
                        Divider(height: 20),
                      ],
                    ),
                ] else ...[
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Article')),
                      DataColumn(label: Text('Référence')),
                      DataColumn(label: Text('Qté'), numeric: true),
                      DataColumn(label: Text('Prix HT'), numeric: true),
                      DataColumn(label: Text('TVA %'), numeric: true),
                      DataColumn(label: Text('Total HT'), numeric: true),
                      DataColumn(label: Text('Total TTC'), numeric: true),
                    ],
                    rows:
                        facture['articles'].map<DataRow>((article) {
                          return DataRow(
                            cells: [
                              DataCell(Text(article['nom'])),
                              DataCell(Text(article['reference'])),
                              DataCell(Text(article['quantite'].toString())),
                              DataCell(
                                Text(
                                  currencyFormat.format(
                                    article['prixUnitaireHT'],
                                  ),
                                ),
                              ),
                              DataCell(Text('${article['tauxTVA']}%')),
                              DataCell(
                                Text(currencyFormat.format(article['totalHT'])),
                              ),
                              DataCell(
                                Text(
                                  currencyFormat.format(article['totalTTC']),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ],

                SizedBox(height: 20),

                // Totaux
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      _buildTotalRow(
                        'Sous-total HT:',
                        facture['totalHT'],
                        currencyFormat,
                      ),
                      _buildTotalRow(
                        'TVA (${facture['tauxTVA']}%):',
                        facture['tva'],
                        currencyFormat,
                      ),
                      Divider(),
                      _buildTotalRow(
                        'Total TTC:',
                        facture['total'],
                        currencyFormat,
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                // Commentaire
                if (facture['commentaire'] != null &&
                    facture['commentaire'].isNotEmpty) ...[
                  Text(
                    'Commentaire:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(facture['commentaire']),
                  SizedBox(height: 15),
                ],

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _generatePdf(facture);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 18),
                          SizedBox(width: 5),
                          Text('Exporter PDF'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 10),
          if (isStatus)
            _getStatusBadge(value)
          else
            Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double value,
    NumberFormat format, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            format.format(value),
            style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
