import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'article.dart';
import 'client.dart';
import 'historiqueDevis.dart';
class DevisMobileScreen extends StatefulWidget {
  @override
  _DevisMobileScreenState createState() => _DevisMobileScreenState();
}

class _DevisMobileScreenState extends State<DevisMobileScreen> with SingleTickerProviderStateMixin {
  // Contrôleurs pour la méthode complète
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _adresseLivraisonController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController(text: '0');
  final TextEditingController _conditionsPaiementController = TextEditingController(text: '30 jours fin de mois');
  final TextEditingController _validiteController = TextEditingController(text: '30');

  // Contrôleurs pour la méthode rapide
  final TextEditingController _rapideClientController = TextEditingController();
  final TextEditingController _rapideReferenceController = TextEditingController();

  // Variables d'état
  DateTime _selectedDate = DateTime.now();
  String? _selectedClient;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalDevis = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;
  File? _imageDevis;
  TabController? _tabController;

  // Données
  List<String> _clients = ['Client 1', 'Client 2', 'Client 3'];
  List<Map<String, dynamic>> _listeArticles = [
    {'nom': 'Produit A', 'prixHT': 100.0},
    {'nom': 'Produit B', 'prixHT': 75.0},
    {'nom': 'Service C', 'prixHT': 50.0},
  ];

  List<Map<String, dynamic>> _historiqueDevis = [];
  String? _selectedArticle;
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController(text: '20.0');
  final TextEditingController _descriptionController = TextEditingController();

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DT', decimalDigits: 2);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formRapideKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerHistorique();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _chargerHistorique() {
    setState(() {
      _historiqueDevis = [
        {
          'reference': 'DEV-2023-001',
          'client': 'Client 1',
          'date': '15/06/2023',
          'total': 1200.0,
          'statut': 'En attente',
          'articles': [
            {'nom': 'Produit A', 'quantite': 2, 'prixHT': 100.0},
          ],
          'adresse': 'Adresse de livraison',
          'conditions': '30 jours fin de mois',
          'validite': '30',
          'remise': '0',
          'methode': 'complète',
        },
        {
          'reference': 'DEV-2023-002',
          'client': 'Client 2',
          'date': '20/06/2023',
          'total': 850.0,
          'statut': 'Accepté',
          'articles': [],
          'adresse': 'Adresse principale',
          'conditions': '45 jours',
          'validite': '15',
          'remise': '5',
          'methode': 'rapide',
          'image': 'assets/placeholder_devis.png',
        },
      ];
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
    double sousTotal = _articles.fold(0.0, (sum, article) => sum + article['montantHT']);
    double totalTVA = _articles.fold(0.0, (sum, article) => sum + article['montantTVA']);
    double remise = double.tryParse(_remiseController.text) ?? 0.0;

    setState(() {
      _sousTotal = sousTotal;
      _totalTVA = totalTVA;
      _totalHT = sousTotal - remise;
      _totalDevis = sousTotal + totalTVA - remise;
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

  void _enregistrerDevis() {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      setState(() {
        _historiqueDevis.insert(0, {
          'reference': _referenceController.text,
          'client': _selectedClient,
          'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
          'total': _totalDevis,
          'statut': 'En attente',
          'articles': List.from(_articles),
          'adresse': _adresseLivraisonController.text,
          'conditions': _conditionsPaiementController.text,
          'validite': _validiteController.text,
          'remise': _remiseController.text,
          'methode': 'complète',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Devis enregistré avec succès"),
          backgroundColor: Colors.teal,
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

  void _enregistrerDevisRapide() async {
    if (_formRapideKey.currentState!.validate()) {
      if (_imageDevis == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez prendre une photo du devis"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _historiqueDevis.insert(0, {
          'reference': _rapideReferenceController.text,
          'client': _rapideClientController.text,
          'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          'total': 0.0,
          'statut': 'En attente',
          'articles': [],
          'adresse': 'À déterminer',
          'conditions': 'À déterminer',
          'validite': '30',
          'remise': '0',
          'methode': 'rapide',
          'image': _imageDevis!.path,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Devis rapide enregistré"),
          backgroundColor: Colors.teal,
        ),
      );

      // Réinitialiser le formulaire rapide
      _rapideClientController.clear();
      _rapideReferenceController.clear();
      setState(() {
        _imageDevis = null;
      });
    }
  }

  Future<void> _prendrePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageDevis = File(pickedFile.path);
      });
    }
  }

  void _chargerDevis(Map<String, dynamic> devis) {
    setState(() {
      _referenceController.text = devis['reference'];
      _selectedClient = devis['client'];
      _selectedDate = DateFormat('dd/MM/yyyy').parse(devis['date']);
      _articles = List.from(devis['articles']);
      _adresseLivraisonController.text = devis['adresse'];
      _conditionsPaiementController.text = devis['conditions'];
      _validiteController.text = devis['validite'];
      _remiseController.text = devis['remise'];
      _calculerTotal();
    });
  }

  Future<void> _navigateToAddArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticleFormScreen(
    onSave: (article) async {
      // Handle saving the article here
      print('Saving article: $article');
      // You can return something if needed
      return;
    },
  ),),
    );
    
    if (result != null) {
      _ajouterArticle(result);
      setState(() {
        _listeArticles.add({
          'nom': result['nom'],
          'prixHT': result['prixHT'],
        });
      });
    }
  }

  Future<void> _navigateToAddClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Client(clientData: {},)),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _clients.add(result);
        _selectedClient = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Création de devis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal, // Changement de couleur pour différencier des bons de commande
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoriqueDevisScreen(),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.list_alt)), 
            Tab(icon: Icon(Icons.bolt)),
          ],
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
                        decoration: _inputDecoration('Référence du devis', Icons.numbers),
                        validator: _requiredValidator,
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: _inputDecoration('Date', Icons.calendar_today),
                          child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: _inputDecoration('Référence du devis', Icons.numbers),
                              validator: _requiredValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: _inputDecoration('Date', Icons.calendar_today),
                                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _validiteController,
                      decoration: _inputDecoration('Validité (jours)', Icons.timer),
                      keyboardType: TextInputType.number,
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _conditionsPaiementController,
                      decoration: _inputDecoration('Conditions de paiement', Icons.payment),
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
                            onChanged: (String? newValue) => setState(() => _selectedClient = newValue),
                            items: _clients.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: _inputDecoration('Sélectionner un client', Icons.person),
                            validator: (value) => value == null ? 'Veuillez sélectionner un client' : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Colors.teal),
                          onPressed: _navigateToAddClient,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _adresseLivraisonController,
                      decoration: _inputDecoration('Adresse de livraison', Icons.location_on),
                      validator: _requiredValidator,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Articles proposés', isSmallScreen),
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
                                  (article) => article['nom'] == value,
                                  orElse: () => {'prixHT': 0.0},
                                );
                                _prixController.text = article['prixHT'].toString();
                              });
                            },
                            items: _listeArticles.map((article) {
                              return DropdownMenuItem<String>(
                                value: article['nom'],
                                child: Text(article['nom']),
                              );
                            }).toList(),
                            decoration: _inputDecoration('Sélectionner un article', Icons.list),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: Colors.teal),
                          onPressed: _navigateToAddArticle,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    if (isSmallScreen) ...[
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Description détaillée', Icons.description),
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _quantiteController,
                        decoration: _inputDecoration('Quantité', Icons.format_list_numbered),
                        keyboardType: TextInputType.number,
                        validator: _quantityValidator,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _prixController,
                        decoration: _inputDecoration('Prix unitaire HT', Icons.attach_money),
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
                              decoration: _inputDecoration('Description détaillée', Icons.description),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteController,
                              decoration: _inputDecoration('Quantité', Icons.format_list_numbered),
                              keyboardType: TextInputType.number,
                              validator: _quantityValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _prixController,
                              decoration: _inputDecoration('Prix HT', Icons.attach_money),
                              keyboardType: TextInputType.number,
                              validator: _priceValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _tvaController,
                              decoration: _inputDecoration('TVA (%)', Icons.percent),
                              keyboardType: TextInputType.number,
                              validator: _tvaValidator,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedArticle != null && _formKey.currentState!.validate()) {
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
              _buildSectionHeader('Détail des articles proposés', isSmallScreen),
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: _articles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final article = entry.value;
                      return ListTile(
                        title: Text(article['nom']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article['description'] != null && article['description'].isNotEmpty)
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
                      decoration: _inputDecoration('Remise (€)', Icons.discount),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculerTotal(),
                      validator: _discountValidator,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    _buildTotalLine('Sous-total HT:', _sousTotal),
                    _buildTotalLine('TVA:', _totalTVA),
                    if (double.parse(_remiseController.text) > 0)
                      _buildTotalLine('Remise:', -double.parse(_remiseController.text), isDiscount: true),
                    Divider(),
                    _buildTotalLine('Total HT:', _totalHT, isBold: true),
                    _buildTotalLine('Total TTC:', _totalDevis, isBold: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _enregistrerDevis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("PDF généré avec succès"),
                          backgroundColor: const Color.fromARGB(255, 66, 73, 66),
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
            'Prenez simplement une photo du devis papier et saisissez les informations essentielles.',
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
                    decoration: _inputDecoration('Référence du devis', Icons.numbers),
                    validator: _requiredValidator,
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedClient,
                          onChanged: (String? newValue) => setState(() => _selectedClient = newValue),
                          items: _clients.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: _inputDecoration('Sélectionner un client', Icons.person),
                          validator: (value) => value == null ? 'Veuillez sélectionner un client' : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: Colors.teal),
                        onPressed: _navigateToAddClient,
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                  Text(
                    'Photo du devis',
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
                      child: _imageDevis == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Appuyez pour prendre une photo'),
                              ],
                            )
                          : Image.file(_imageDevis!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_imageDevis != null)
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
                onPressed: _enregistrerDevisRapide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(150, 50),
                ),
                child: Text('Enregistrer'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formRapideKey.currentState!.validate() && _imageDevis != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("PDF généré avec succès"),
                        backgroundColor: const Color.fromARGB(255, 66, 73, 66),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
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
          color: Colors.teal, // Changement de couleur pour correspondre au thème devis
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

  Widget _buildTotalLine(String label, double value, {bool isBold = false, bool isDiscount = false}) {
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
    if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Quantité invalide';
    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Prix invalide';
    return null;
  }

  String? _tvaValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) < 0) return 'TVA invalide';
    return null;
  }

  String? _discountValidator(String? value) {
    if (value == null || value.isEmpty) return 'Champ requis';
    if (double.tryParse(value) == null || double.parse(value) < 0) return 'Remise invalide';
    return null;
  }
}