// Dart Core
import 'dart:io';
import 'dart:typed_data';

// Flutter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// PDF Generation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// File Handling
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

// Utilities
import 'package:intl/intl.dart';

// Models
import 'article.dart';
import 'client.dart';
import '../services/achat_service.dart';
import '../models/Vente.dart';

class BonCommandeMobileScreen extends StatefulWidget {
  @override
  _BonCommandeMobileScreenState createState() =>
      _BonCommandeMobileScreenState();
}

class _BonCommandeMobileScreenState extends State<BonCommandeMobileScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleurs pour la méthode complète
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _adresseLivraisonController =
      TextEditingController();
  final TextEditingController _remiseController = TextEditingController(
    text: '0',
  );
  final TextEditingController _delaiLivraisonController = TextEditingController(
    text: '15',
  );
  final TextEditingController _conditionsPaiementController =
      TextEditingController(text: '30 jours fin de mois');

  // Contrôleurs pour la méthode rapide
  final TextEditingController _rapideClientController = TextEditingController();
  final TextEditingController _rapideReferenceController =
      TextEditingController();

  // Variables d'état
  DateTime _selectedDate = DateTime.now();
  String? _selectedClient;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalCommande = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;
  File? _imageBonCommande;
  TabController? _tabController;

  // Données
  List<Map<String, String>> _clients = [];
  List<Map<String, dynamic>> _listeArticles = [];

  List<VenteBonCommande> _historiqueCommandes = [];
  String? _selectedArticle;
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController(
    text: '20.0',
  );
  final TextEditingController _descriptionController = TextEditingController();

  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formRapideKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerHistorique();
    _refreshData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _chargerHistorique() async {
    final venteService = PurchaseService();

    venteService.fetchVentes("?method=complete").then((result) {
      setState(() {
        _historiqueCommandes = result;
      });
    });
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
      _totalHT = sousTotal - remise;
      _totalCommande = sousTotal + totalTVA - remise;
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

  final PurchaseService _purchaseService = PurchaseService();

  void _enregistrerCommande() async {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      setState(() {
        _historiqueCommandes.insert(
          0,
          VenteBonCommande.fromJson({
            'reference': _referenceController.text,
            'client': _selectedClient,
            'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
            'total': _totalCommande,
            'statut': 'En attente',
            'articles': List.from(_articles),
            'adresse': _adresseLivraisonController.text,
            'conditions': _conditionsPaiementController.text,
            'delaiLivraison': _delaiLivraisonController.text,
            'remise': _remiseController.text,
            'methode': 'complète',
          }),
        );
      });
      await _purchaseService.saveVente({
        'reference': _referenceController.text,
        'client': _selectedClient ?? "",
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
        'total': _totalCommande,
        'statut': 'En attente',
        'articles': List.from(_articles),
        'adresse': _adresseLivraisonController.text,
        'conditions': _conditionsPaiementController.text,
        'delaiLivraison': _delaiLivraisonController.text,
        'remise': _remiseController.text,
        'methode': 'complète',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bon de commande enregistré avec succès"),
          backgroundColor: Colors.blue,
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

  void _enregistrerCommandeRapide() async {
    if (_formRapideKey.currentState!.validate()) {
      if (_imageBonCommande == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez prendre une photo du bon de commande"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _historiqueCommandes.insert(
          0,
          VenteBonCommande.fromJson({
            'reference': _rapideReferenceController.text,
            'client': _rapideClientController.text,
            'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
            'total': 0.0,
            'statut': 'En attente',
            'articles': [],
            'adresse': 'À déterminer',
            'conditions': 'À déterminer',
            'delaiLivraison': 'À déterminer',
            'remise': '0',
            'methode': 'rapide',
            'image': _imageBonCommande!.path,
          }),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bon de commande rapide enregistré"),
          backgroundColor: Colors.blue,
        ),
      );

      // Réinitialiser le formulaire rapide
      _rapideClientController.clear();
      _rapideReferenceController.clear();
      setState(() {
        _imageBonCommande = null;
      });
    }
  }

  Future<void> _prendrePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageBonCommande = File(pickedFile.path);
      });
    }
  }

  void _chargerCommande(Map<String, dynamic> commande) {
    setState(() {
      _referenceController.text = commande['reference'];
      _selectedClient = commande['client'];
      _selectedDate = DateFormat('dd/MM/yyyy').parse(commande['date']);
      _articles = List.from(commande['articles']);
      _adresseLivraisonController.text = commande['adresse'];
      _conditionsPaiementController.text = commande['conditions'];
      _delaiLivraisonController.text = commande['delaiLivraison'];
      _remiseController.text = commande['remise'];
      _calculerTotal();
    });
  }

  Future<void> _navigateToAddArticle() async {
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

    if (result != null) {
      _ajouterArticle(result);
      setState(() {
        _listeArticles.add({'nom': result['nom'], 'prixHT': result['prixHT']});
      });
    }
  }

  Future<void> _navigateToAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Client(clientData: {})),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _clients.add(result);
        _selectedClient = result;
      });
    }
  }

  void _refreshData() {
    setState(() {
      _purchaseService.getfetchClient().then((clients) {
        setState(() {
          _clients = clients;
        });
      });
      ;
      _purchaseService.getArticles().then((articles) {
        setState(() {
          _listeArticles = articles;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Création de bon de commande',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoriqueVenteScreen(),
                  ),
                ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(icon: Icon(Icons.list_alt)), Tab(icon: Icon(Icons.bolt))],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Méthode complète
          _buildMethodeComplete(isSmallScreen),
          // Méthode rapide
          _buildMethodeRapide(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildMethodeComplete(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Informations Générales', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    if (isSmallScreen) ...[
                      TextFormField(
                        controller: _referenceController,
                        decoration: _inputDecoration(
                          'Référence du bon',
                          Icons.numbers,
                        ),
                        validator: _requiredValidator,
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            'Date',
                            Icons.calendar_today,
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: _inputDecoration(
                                'Référence du bon',
                                Icons.numbers,
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                  'Date',
                                  Icons.calendar_today,
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
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _delaiLivraisonController,
                      decoration: _inputDecoration(
                        'Délai de livraison (jours)',
                        Icons.local_shipping,
                      ),
                      keyboardType: TextInputType.number,
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _conditionsPaiementController,
                      decoration: _inputDecoration(
                        'Conditions de paiement',
                        Icons.payment,
                      ),
                      validator: _requiredValidator,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Client', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedClient,
                            onChanged:
                                (String? newValue) =>
                                    setState(() => _selectedClient = newValue),
                            items:
                                _clients.map((value) {
                                  print(value);
                                  return DropdownMenuItem<String>(
                                    value: value['id'],
                                    child: Text(value['name'] ?? "inconu"),
                                  );
                                }).toList(),
                            decoration: _inputDecoration(
                              'Sélectionner un client',
                              Icons.person,
                            ),
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Veuillez sélectionner un client'
                                        : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.teal,
                          ),
                          onPressed: _navigateToAddClient,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _adresseLivraisonController,
                      decoration: _inputDecoration(
                        'Adresse de livraison',
                        Icons.location_on,
                      ),
                      validator: _requiredValidator,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Articles commandés', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedArticle,
                            onChanged: (value) {
                              setState(() {
                                _selectedArticle = value;
                                var article = _listeArticles.firstWhere(
                                  (article) => article['id'] == value,
                                );
                                _prixController.text =
                                    article['prixHT'].toString();
                              });
                            },
                            items:
                                _listeArticles.map((article) {
                                  return DropdownMenuItem<String>(
                                    value: article['id'],
                                    child: Text(article['name'] ?? "inconu"),
                                  );
                                }).toList(),
                            decoration: _inputDecoration(
                              'Sélectionner un article',
                              Icons.list,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.teal,
                          ),
                          onPressed: _navigateToAddArticle,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    if (isSmallScreen) ...[
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration(
                          'Description détaillée',
                          Icons.description,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _quantiteController,
                        decoration: _inputDecoration(
                          'Quantité',
                          Icons.format_list_numbered,
                        ),
                        keyboardType: TextInputType.number,
                        validator: _quantityValidator,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _prixController,
                        decoration: _inputDecoration(
                          'Prix unitaire HT',
                          Icons.attach_money,
                        ),
                        keyboardType: TextInputType.number,
                        validator: _priceValidator,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _tvaController,
                        decoration: _inputDecoration('TVA (%)', Icons.percent),
                        keyboardType: TextInputType.number,
                        validator: _tvaValidator,
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: _inputDecoration(
                                'Description détaillée',
                                Icons.description,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteController,
                              decoration: _inputDecoration(
                                'Quantité',
                                Icons.format_list_numbered,
                              ),
                              keyboardType: TextInputType.number,
                              validator: _quantityValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _prixController,
                              decoration: _inputDecoration(
                                'Prix HT',
                                Icons.attach_money,
                              ),
                              keyboardType: TextInputType.number,
                              validator: _priceValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _tvaController,
                              decoration: _inputDecoration(
                                'TVA (%)',
                                Icons.percent,
                              ),
                              keyboardType: TextInputType.number,
                              validator: _tvaValidator,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedArticle != null &&
                            _formKey.currentState!.validate()) {
                          _ajouterArticle({
                            'nom': _selectedArticle!,
                            'description': _descriptionController.text,
                            'quantite': int.parse(_quantiteController.text),
                            'prixHT': double.parse(_prixController.text),
                            'tva': double.parse(_tvaController.text),
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Ajouter l\'article'),
                    ),
                  ],
                ),
              ),
            ),
            if (_articles.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildSectionHeader(
                'Détail des articles commandés',
                isSmallScreen,
              ),
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children:
                        _articles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final article = entry.value;
                          return ListTile(
                            title: Text(article['nom']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article['description'] != null &&
                                    article['description'].isNotEmpty)
                                  Text(article['description']),
                                Text(
                                  'Quantité: ${article['quantite']} - Prix HT: ${currencyFormat.format(article['prixHT'])} - TVA: ${article['tva']}%',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _supprimerArticle(index),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            _buildSectionHeader('Totaux', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _remiseController,
                      decoration: _inputDecoration(
                        'Remise (€)',
                        Icons.discount,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculerTotal(),
                      validator: _discountValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    _buildTotalLine('Sous-total HT:', _sousTotal),
                    _buildTotalLine('TVA:', _totalTVA),
                    if (double.parse(_remiseController.text) > 0)
                      _buildTotalLine(
                        'Remise:',
                        -double.parse(_remiseController.text),
                        isDiscount: true,
                      ),
                    Divider(),
                    _buildTotalLine('Total HT:', _totalHT, isBold: true),
                    _buildTotalLine('Total TTC:', _totalCommande, isBold: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _enregistrerCommande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _articles.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("PDF généré avec succès"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            66,
                            73,
                            66,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Générer PDF'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodeRapide(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
      child: Form(
        key: _formRapideKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Méthode Rapide', isSmallScreen),
            Text(
              'Prenez simplement une photo du bon de commande papier et saisissez les informations essentielles.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _rapideReferenceController,
                      decoration: _inputDecoration(
                        'Référence du bon',
                        Icons.numbers,
                      ),
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _rapideClientController,
                      decoration: _inputDecoration('Client', Icons.person),
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    Text(
                      'Photo du bon de commande',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _prendrePhoto,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            _imageBonCommande == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Appuyez pour prendre une photo'),
                                  ],
                                )
                                : Image.file(
                                  _imageBonCommande!,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_imageBonCommande != null)
                      TextButton(
                        onPressed: _prendrePhoto,
                        child: Text('Reprendre la photo'),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _enregistrerCommandeRapide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formRapideKey.currentState!.validate() &&
                        _imageBonCommande != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("PDF généré avec succès"),
                          backgroundColor: const Color.fromARGB(
                            255,
                            66,
                            73,
                            66,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Générer PDF'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      prefixIcon: Icon(icon),
    );
  }

  Widget _buildTotalLine(
    String label,
    double value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            currencyFormat.format(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    return value == null || value.isEmpty ? 'Champ requis' : null;
  }

  String? _quantityValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (int.tryParse(value) == null || int.parse(value) <= 0)
      return 'Quantité invalide';
    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) <= 0)
      return 'Prix invalide';
    return null;
  }

  String? _tvaValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) < 0)
      return 'TVA invalide';
    return null;
  }

  String? _discountValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) < 0)
      return 'Remise invalide';
    return null;
  }
}

class HistoriqueVenteScreen extends StatefulWidget {
  @override
  _HistoriqueVenteScreenState createState() => _HistoriqueVenteScreenState();
}

class _HistoriqueVenteScreenState extends State<HistoriqueVenteScreen> {
  List<VenteBonCommande> _allCommandes = [];
  List<VenteBonCommande> _filteredCommandes = [];
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );
  String _currentFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadCommandes();
    _searchController.addListener(_filterCommandes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCommandes() {
    final venteService = PurchaseService();

    venteService.fetchVentes("?method=complete").then((result) {
      setState(() {
        _allCommandes = result;
        _filteredCommandes = List.from(_allCommandes);
      });
    });
  }

  void _filterCommandes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommandes =
          _allCommandes.where((commande) {
            final matchesSearch =
                commande.reference.toLowerCase().contains(query) ||
                commande.client.toLowerCase().contains(query);

            final matchesFilter =
                _currentFilter == 'Tous' || (_currentFilter == 'Formulaire');

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  void _changeFilter(String? newValue) {
    if (newValue != null) {
      setState(() {
        _currentFilter = newValue;
        _filterCommandes();
      });
    }
  }

  void _deleteCommande(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer cette commande ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final commandeToDelete = _filteredCommandes[index];
                  final indexInAll = _allCommandes.indexOf(commandeToDelete);
                  if (indexInAll != -1) {
                    _allCommandes.removeAt(indexInAll);
                  }
                  _filterCommandes();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Commande supprimée avec succès'),
                    backgroundColor: Colors.red,
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

  void _editCommande(Map<String, dynamic> commande) {
    // Implémentation de la fonction d'édition
    if (commande['type'] == 'formulaire') {
      // Navigation vers l'écran d'édition pour les commandes formulaire
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BonCommandeMobileScreen()),
      ).then((value) {
        if (value != null) {
          setState(() {
            _loadCommandes();
          });
        }
      });
    } else {
      // Navigation vers l'écran d'édition pour les commandes photo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPhotoScreen(commande: commande),
        ),
      ).then((value) {
        if (value != null) {
          setState(() {
            _loadCommandes();
          });
        }
      });
    }
  }

  void _showCommandeDetails(Map<String, dynamic> commande) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Détails de la commande',
            style: TextStyle(color: Colors.teal.shade700),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (commande['type'] == 'photo' &&
                    commande['photo'] != null) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: commande['photo'],
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                ],
                _buildDetailItem(
                  'Type:',
                  commande['type'] == 'formulaire' ? 'Formulaire' : 'Photo',
                ),
                _buildDetailItem('Référence:', commande['reference']),
                _buildDetailItem('Client:', commande['client']),
                _buildDetailItem('Date:', commande['date']),
                _buildDetailItem('Statut:', commande['statut']),
                _buildDetailItem(
                  'Total:',
                  currencyFormat.format(commande['total']),
                ),
                _buildDetailItem('Adresse:', commande['adresse']),
                _buildDetailItem('Délai livraison:', commande['livraison']),
                _buildDetailItem('Remise:', '${commande['remise']} €'),

                if (commande['type'] == 'formulaire') ...[
                  SizedBox(height: 16),
                  Text(
                    'Articles:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  ...commande['articles']
                      .map<Widget>(
                        (article) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- ${article['nom']} (x${article['quantite']}) - ${currencyFormat.format(article['prixHT'])} HT',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      )
                      .toList(),
                ],
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }

  // Méthode auxiliaire pour les cellules d'en-tête du tableau PDF
  pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Méthode auxiliaire pour les cellules de données du tableau PDF
  pw.Widget _dataCell(String text) {
    return pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(text));
  }

  // Méthode auxiliaire pour les lignes de total dans le PDF
  pw.Widget _totalLine(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(
            value,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(Map<String, dynamic> commande) async {
    try {
      // Couleurs & styles
      final tealColor = PdfColor.fromInt(Colors.teal.value);
      final blackColor = PdfColor.fromInt(Colors.black.value);

      final headerStyle = pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
        color: tealColor,
      );
      final subtitleStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: blackColor,
      );
      final normalStyle = pw.TextStyle(fontSize: 12, color: blackColor);
      final totalStyle = pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: tealColor,
      );

      // Logo
      pw.MemoryImage? logoImage;
      try {
        final ByteData logoData = await rootBundle.load('images/logo.png');
        final Uint8List logoBytes = logoData.buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      } catch (e) {
        print('Erreur de chargement du logo: $e');
      }

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
                    logoImage != null
                        ? pw.Container(height: 80, child: pw.Image(logoImage))
                        : pw.Container(
                          height: 80,
                          child: pw.Text('LOGO', style: headerStyle),
                        ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Adresse: Rue dela nouvelle Delhi , Belvédére Tunis',
                        ),
                        pw.Text('Tél: 9230991'),
                        pw.Text('Email: contact@esprit-climatique.tn'),
                        pw.Text('Matricule fiscale: 1883626X/A/M/000'),
                      ],
                    ),
                  ],
                ),

                pw.Divider(color: tealColor, thickness: 2),
                pw.SizedBox(height: 20),

                // Titre
                pw.Center(
                  child: pw.Text(
                    'DEVIS / BON DE COMMANDE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: tealColor,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Infos commande
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Référence: ${commande['reference'] ?? 'N/A'}',
                          style: normalStyle,
                        ),
                        pw.Text(
                          'Date: ${commande['date'] ?? 'N/A'}',
                          style: normalStyle,
                        ),
                        pw.Text(
                          'Statut: ${commande['statut'] ?? 'N/A'}',
                          style: normalStyle,
                        ),
                        pw.Text(
                          'Type: ${commande['type'] == 'formulaire' ? 'Formulaire' : 'Photo'}',
                          style: normalStyle,
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Client: ${commande['client'] ?? 'N/A'}',
                          style: normalStyle,
                        ),
                        pw.Text(
                          'Adresse: ${commande['adresse'] ?? 'N/A'}',
                          style: normalStyle,
                        ),
                        if (commande['livraison'] != null)
                          pw.Text(
                            'Livraison: ${commande['livraison']}',
                            style: normalStyle,
                          ),
                      ],
                    ),
                  ],
                ),

                // Articles ou image scannée
                if (commande['type'] == 'formulaire' &&
                    commande['articles'] is List &&
                    (commande['articles'] as List).isNotEmpty) ...[
                  pw.SizedBox(height: 30),
                  pw.Text('Articles commandés:', style: subtitleStyle),
                  pw.SizedBox(height: 10),
                  pw.Table(
                    border: pw.TableBorder.all(color: tealColor, width: 1),
                    columnWidths: {
                      0: pw.FlexColumnWidth(3),
                      1: pw.FlexColumnWidth(1),
                      2: pw.FlexColumnWidth(1.5),
                      3: pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: tealColor),
                        children: [
                          _headerCell('Article'),
                          _headerCell('Qté'),
                          _headerCell('Prix HT (Dinars)'),
                          _headerCell('Total (Dinars)'),
                        ],
                      ),
                      ...(commande['articles'] as List).map<pw.TableRow>((
                        article,
                      ) {
                        final nom = article['nom'] ?? '';
                        final quantite = (article['quantite'] as num?) ?? 0;
                        final prixHT = (article['prixHT'] as num?) ?? 0.0;
                        final total = quantite * prixHT;

                        return pw.TableRow(
                          children: [
                            _dataCell(nom),
                            _dataCell(quantite.toString()),
                            _dataCell('${prixHT.toStringAsFixed(3)} dt'),
                            _dataCell('${total.toStringAsFixed(3)} dt'),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ] else if (commande['photo'] != null) ...[
                  pw.SizedBox(height: 30),
                  pw.Text('Bon de commande scanné:', style: subtitleStyle),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Container(
                      width: 200,
                      height: 150,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: tealColor),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'Image du bon de commande',
                          style: pw.TextStyle(
                            fontStyle: pw.FontStyle.italic,
                            color: tealColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Totaux
                pw.SizedBox(height: 30),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 300,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: tealColor),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        if ((commande['remise'] as String?) != null &&
                            double.tryParse((commande['remise'] as String?)!) !=
                                null &&
                            double.parse((commande['remise'] as String?)!) > 0)
                          _totalLine('Remise:', '${commande['remise']} dt'),
                        _totalLine(
                          'Total HT:',
                          '${(commande['total'] as num?)?.toStringAsFixed(3) ?? '0'} dt',
                        ),
                        _totalLine(
                          'TVA (20%):',
                          '${((commande['total'] as num?) ?? 0) * 0.2} dt',
                        ),
                        pw.Divider(color: tealColor),
                        _totalLine(
                          'Total TTC:',
                          '${((commande['total'] as num?) ?? 0) * 1.2} dt',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),

                // Pied de page
                pw.SizedBox(height: 40),
                pw.Divider(color: tealColor),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Conditions de paiement: 30 jours fin de mois',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                    pw.Text(
                      'Page ${context.pageNumber}/${context.pagesCount}',
                      style: normalStyle,
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Merci pour votre confiance !',
                    style: pw.TextStyle(
                      color: tealColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Afficher le PDF en mode aperçu
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'commande_${commande['reference']}.pdf',
      );
    } catch (e) {
      print('Erreur lors de la génération du PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Livré':
        return Colors.green;
      case 'En préparation':
        return Colors.orange;
      case 'Validé':
        return Colors.blue;
      case 'En cours':
        return Colors.blue.shade300;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCommandeCard(VenteBonCommande commande, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    commande.reference,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    'Formulaire',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: Colors.blueGrey,

                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    commande.client,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                Chip(
                  label: Text(
                    commande.statut,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(commande.statut),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${commande.date}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  'Livraison: ${commande.delaiLivraison}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Total: ${currencyFormat.format(commande.total)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                  onPressed: () => _showCommandeDetails(commande.toJson()),
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.orange),
                  onPressed: () => _generatePdf(commande.toJson()),
                ),
                /* if (commande['type'] == 'formulaire')
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.purple),
                    onPressed: () => _editCommande(commande),
                  ),
                  */
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCommande(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique des commandes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Navigation vers l'écran de création de commande
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher par référence ou client',
                    labelStyle: TextStyle(color: Colors.teal),
                    prefixIcon: Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.teal),
                              onPressed: () {
                                _searchController.clear();
                                _filterCommandes();
                              },
                            )
                            : null,
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _currentFilter,
                  items:
                      ['Tous', 'Formulaire', 'Photo'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: _changeFilter,
                  decoration: InputDecoration(
                    labelText: 'Filtrer par type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredCommandes.isEmpty
                    ? Center(
                      child: Text(
                        'Aucune commande trouvée',
                        style: TextStyle(color: Colors.teal, fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: _filteredCommandes.length,
                      itemBuilder: (context, index) {
                        final commande = _filteredCommandes[index];
                        return _buildCommandeCard(commande, index);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class EditPhotoScreen extends StatelessWidget {
  final Map<String, dynamic> commande;

  const EditPhotoScreen({Key? key, required this.commande}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier commande photo')),
      body: Center(child: Text('Écran de modification pour commande photo')),
    );
  }
}
