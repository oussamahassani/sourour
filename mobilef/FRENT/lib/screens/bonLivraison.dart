import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'article.dart';
import 'client.dart';

class BonLivraisonMobileScreen extends StatefulWidget {
  @override
  _BonLivraisonMobileScreenState createState() => _BonLivraisonMobileScreenState();
}

class _BonLivraisonMobileScreenState extends State<BonLivraisonMobileScreen> with SingleTickerProviderStateMixin {
  // Contrôleurs pour la méthode complète
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _adresseLivraisonController = TextEditingController();
  final TextEditingController _referenceCommandeController = TextEditingController();
  final TextEditingController _transporteurController = TextEditingController();
  final TextEditingController _numeroTrackingController = TextEditingController();

  // Contrôleurs pour la méthode rapide
  final TextEditingController _rapideClientController = TextEditingController();
  final TextEditingController _rapideReferenceController = TextEditingController();

  // Variables d'état
  DateTime _selectedDate = DateTime.now();
  String? _selectedClient;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalLivraison = 0.0;
  File? _imageBonLivraison;
  TabController? _tabController;

  // Données
  List<String> _clients = ['Client 1', 'Client 2', 'Client 3'];
  List<String> _transporteurs = ['Transporteur A', 'Transporteur B', 'Transporteur C'];
  List<Map<String, dynamic>> _listeArticles = [
    {'nom': 'Produit A', 'prixHT': 100.0},
    {'nom': 'Produit B', 'prixHT': 75.0},
    {'nom': 'Service C', 'prixHT': 50.0},
  ];

  List<Map<String, dynamic>> _historiqueLivraisons = [];
  String? _selectedArticle;
  String? _selectedTransporteur;
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _quantiteLivreeController = TextEditingController();
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
      _historiqueLivraisons = [
        {
          'reference': 'BL-2023-001',
          'client': 'Client 1',
          'date': '20/06/2023',
          'total': 1200.0,
          'statut': 'Livré',
          'articles': [
            {'nom': 'Produit A', 'quantite': 2, 'quantiteLivree': 2, 'prixHT': 100.0},
          ],
          'adresse': 'Adresse de livraison',
          'referenceCommande': 'BC-2023-001',
          'transporteur': 'Transporteur A',
          'numeroTracking': 'TRACK123456',
          'methode': 'complète',
        },
        {
          'reference': 'BL-2023-002',
          'client': 'Client 2',
          'date': '25/06/2023',
          'total': 850.0,
          'statut': 'En transit',
          'articles': [],
          'adresse': 'Adresse principale',
          'referenceCommande': 'BC-2023-002',
          'transporteur': 'Transporteur B',
          'numeroTracking': 'TRACK654321',
          'methode': 'rapide',
          'image': 'assets/placeholder_bon.png',
        },
      ];
    });
  }

  void _ajouterArticle(Map<String, dynamic> article) {
    setState(() {
      double prixHT = article['prixHT'];
      int quantite = article['quantite'];
      int quantiteLivree = article['quantiteLivree'];
      String description = article['description'] ?? '';

      _articles.add({
        'nom': article['nom'],
        'description': description,
        'quantite': quantite,
        'quantiteLivree': quantiteLivree,
        'prixHT': prixHT,
        'montantHT': prixHT * quantiteLivree,
      });
      _calculerTotal();

      _selectedArticle = null;
      _prixController.clear();
      _quantiteController.clear();
      _quantiteLivreeController.clear();
      _descriptionController.clear();
    });
  }

  void _calculerTotal() {
    double totalLivraison = _articles.fold(0.0, (sum, article) => sum + article['montantHT']);

    setState(() {
      _totalHT = totalLivraison;
      _totalLivraison = totalLivraison;
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

  void _enregistrerLivraison() {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      setState(() {
        _historiqueLivraisons.insert(0, {
          'reference': _referenceController.text,
          'client': _selectedClient,
          'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
          'total': _totalLivraison,
          'statut': 'Préparé',
          'articles': List.from(_articles),
          'adresse': _adresseLivraisonController.text,
          'referenceCommande': _referenceCommandeController.text,
          'transporteur': _selectedTransporteur,
          'numeroTracking': _numeroTrackingController.text,
          'methode': 'complète',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bon de livraison enregistré avec succès"),
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

  void _enregistrerLivraisonRapide() async {
    if (_formRapideKey.currentState!.validate()) {
      if (_imageBonLivraison == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez prendre une photo du bon de livraison"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _historiqueLivraisons.insert(0, {
          'reference': _rapideReferenceController.text,
          'client': _rapideClientController.text,
          'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          'total': 0.0,
          'statut': 'En préparation',
          'articles': [],
          'adresse': 'À déterminer',
          'referenceCommande': 'Non spécifié',
          'transporteur': 'Non spécifié',
          'numeroTracking': 'Non spécifié',
          'methode': 'rapide',
          'image': _imageBonLivraison!.path,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bon de livraison rapide enregistré"),
          backgroundColor: Colors.blue,
        ),
      );

      // Réinitialiser le formulaire rapide
      _rapideClientController.clear();
      _rapideReferenceController.clear();
      setState(() {
        _imageBonLivraison = null;
      });
    }
  }

  Future<void> _prendrePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageBonLivraison = File(pickedFile.path);
      });
    }
  }

  void _chargerLivraison(Map<String, dynamic> livraison) {
    setState(() {
      _referenceController.text = livraison['reference'];
      _selectedClient = livraison['client'];
      _selectedDate = DateFormat('dd/MM/yyyy').parse(livraison['date']);
      _articles = List.from(livraison['articles']);
      _adresseLivraisonController.text = livraison['adresse'];
      _referenceCommandeController.text = livraison['referenceCommande'];
      _selectedTransporteur = livraison['transporteur'];
      _numeroTrackingController.text = livraison['numeroTracking'];
      _calculerTotal();
    });
  }

  Future<void> _navigateToAddArticle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ArticleFormScreen(
    onSave: (article) async {
      // Handle saving the article here
      print('Saving article: $article');
      // You can return something if needed
      return;
    },
  ),),
    );
    
    if (result != null) {
      _ajouterArticle({
        'nom': result['nom'],
        'prixHT': result['prixHT'],
        'quantite': result['quantite'] ?? 1,
        'quantiteLivree': result['quantite'] ?? 1,
        'description': result['description'] ?? '',
      });
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
        'Création de bon de livraison',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.teal, // Changement de couleur pour différencier
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.history),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoriqueLivraisonScreen(),
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
    body: Column(
      children: [
        SizedBox(height: 8), // Ajouté ici pour éviter l'erreur
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMethodeComplete(isSmallScreen),
              _buildMethodeRapide(isSmallScreen),
            ],
          ),
        ),
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
                        decoration: _inputDecoration('Référence du BL', Icons.numbers),
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
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _referenceCommandeController,
                        decoration: _inputDecoration('Référence commande', Icons.receipt),
                        validator: _requiredValidator,
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              decoration: _inputDecoration('Référence du BL', Icons.numbers),
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
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _referenceCommandeController,
                              decoration: _inputDecoration('Référence commande', Icons.receipt),
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
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
            _buildSectionHeader('Transport', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedTransporteur,
                      onChanged: (String? newValue) => setState(() => _selectedTransporteur = newValue),
                      items: _transporteurs.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: _inputDecoration('Transporteur', Icons.local_shipping),
                      validator: (value) => value == null ? 'Veuillez sélectionner un transporteur' : null,
                    ),
                    SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                    TextFormField(
                      controller: _numeroTrackingController,
                      decoration: _inputDecoration('Numéro de tracking', Icons.confirmation_number),
                      validator: _requiredValidator,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSectionHeader('Articles livrés', isSmallScreen),
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
                        decoration: _inputDecoration('Description', Icons.description),
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _quantiteController,
                        decoration: _inputDecoration('Quantité commandée', Icons.format_list_numbered),
                        keyboardType: TextInputType.number,
                        validator: _quantityValidator,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _quantiteLivreeController,
                        decoration: _inputDecoration('Quantité livrée', Icons.check_circle),
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
                    ] else
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _descriptionController,
                              decoration: _inputDecoration('Description', Icons.description),
                              maxLines: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteController,
                              decoration: _inputDecoration('Qté commandée', Icons.format_list_numbered),
                              keyboardType: TextInputType.number,
                              validator: _quantityValidator,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteLivreeController,
                              decoration: _inputDecoration('Qté livrée', Icons.check_circle),
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
                            'quantiteLivree': int.parse(_quantiteLivreeController.text),
                            'prixHT': double.parse(_prixController.text),
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
              _buildSectionHeader('Détail des articles livrés', isSmallScreen),
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
                              'Commandé: ${article['quantite']} - Livré: ${article['quantiteLivree']} - Prix HT: ${currencyFormat.format(article['prixHT'])}',
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
            _buildSectionHeader('Total', isSmallScreen),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                child: Column(
                  children: [
                    _buildTotalLine('Total HT:', _totalHT, isBold: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _enregistrerLivraison,
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
                          backgroundColor: Colors.grey[800],
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
              'Prenez simplement une photo du bon de livraison papier et saisissez les informations essentielles.',
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
                      decoration: _inputDecoration('Référence du BL', Icons.numbers),
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
                      'Photo du bon de livraison',
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
                        child: _imageBonLivraison == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Appuyez pour prendre une photo'),
                                ],
                              )
                            : Image.file(_imageBonLivraison!, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_imageBonLivraison != null)
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
                  onPressed: _enregistrerLivraisonRapide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 50),
                  ),
                  child: Text('Enregistrer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formRapideKey.currentState!.validate() && _imageBonLivraison != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("PDF généré avec succès"),
                          backgroundColor: Colors.grey[800],
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

  Widget _buildTotalLine(String label, double value, {bool isBold = false}) {
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
}


class HistoriqueLivraisonScreen extends StatefulWidget {
  @override
  _HistoriqueLivraisonScreenState createState() => _HistoriqueLivraisonScreenState();
}

class _HistoriqueLivraisonScreenState extends State<HistoriqueLivraisonScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DT', decimalDigits: 2);
  List<Map<String, dynamic>> _historiqueLivraisons = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  void _chargerHistorique() {
    setState(() {
      _historiqueLivraisons = [
        {
          'reference': 'BL-2023-001',
          'client': 'Client 1',
          'date': '20/06/2023',
          'total': 1200.0,
          'statut': 'Livré',
          'articles': [
            {'nom': 'Produit A', 'quantite': 2, 'quantiteLivree': 2, 'prixHT': 100.0},
          ],
          'adresse': 'Adresse de livraison',
          'referenceCommande': 'BC-2023-001',
          'transporteur': 'Transporteur A',
          'numeroTracking': 'TRACK123456',
          'methode': 'complète',
        },
        {
          'reference': 'BL-2023-002',
          'client': 'Client 2',
          'date': '25/06/2023',
          'total': 850.0,
          'statut': 'En transit',
          'articles': [],
          'adresse': 'Adresse principale',
          'referenceCommande': 'BC-2023-002',
          'transporteur': 'Transporteur B',
          'numeroTracking': 'TRACK654321',
          'methode': 'rapide',
          'image': 'assets/placeholder_bon.png',
        },
        {
          'reference': 'BL-2023-003',
          'client': 'Client 3',
          'date': '01/07/2023',
          'total': 1500.0,
          'statut': 'Préparé',
          'articles': [
            {'nom': 'Produit B', 'quantite': 3, 'quantiteLivree': 0, 'prixHT': 75.0},
            {'nom': 'Service C', 'quantite': 2, 'quantiteLivree': 0, 'prixHT': 50.0},
          ],
          'adresse': 'Adresse secondaire',
          'referenceCommande': 'BC-2023-003',
          'transporteur': 'Transporteur C',
          'numeroTracking': 'TRACK789012',
          'methode': 'complète',
        },
      ];
    });
  }

  List<Map<String, dynamic>> _getFilteredLivraisons() {
    if (_searchController.text.isEmpty) {
      return _historiqueLivraisons;
    }
    return _historiqueLivraisons.where((livraison) {
      return livraison['reference'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          livraison['client'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          livraison['referenceCommande'].toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Livré':
        return Colors.green;
      case 'En transit':
        return Colors.orange;
      case 'Préparé':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _ouvrirLivraison(Map<String, dynamic> livraison) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BonLivraisonMobileScreen(),
        settings: RouteSettings(arguments: livraison),
      ),
    ).then((_) => _chargerHistorique());
  }

  void _creerNouvelleLivraison() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BonLivraisonMobileScreen()),
    ).then((_) => _chargerHistorique());
  }

  void _supprimerLivraison(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer la suppression"),
          content: Text("Voulez-vous vraiment supprimer ce bon de livraison ?"),
          actions: [
            TextButton(
              child: Text("Annuler"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _historiqueLivraisons.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Bon de livraison supprimé"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _modifierLivraison(Map<String, dynamic> livraison) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BonLivraisonMobileScreen(),
        settings: RouteSettings(arguments: livraison),
      ),
    ).then((_) => _chargerHistorique());
  }

  void _genererPDF(Map<String, dynamic> livraison) {
    // Ici vous intégrerez votre logique de génération de PDF
    // Ceci est une simulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF généré pour ${livraison['reference']}"),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _afficherDetails(Map<String, dynamic> livraison) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails du bon de livraison"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Référence: ${livraison['reference']}", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Client: ${livraison['client']}"),
                Text("Date: ${livraison['date']}"),
                Text("Commande associée: ${livraison['referenceCommande']}"),
                Text("Transporteur: ${livraison['transporteur']}"),
                Text("N° Tracking: ${livraison['numeroTracking']}"),
                Text("Adresse: ${livraison['adresse']}"),
                SizedBox(height: 16),
                Text("Articles:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...livraison['articles'].map<Widget>((article) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
"- ${article['nom']} (Livré: ${article['quantiteLivree']}/${article['quantite']}) - ${currencyFormat.format(article['prixHT'])} HT"
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
              Text(
  "Total: ${currencyFormat.format(livraison['total'])}", 
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
),

              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Fermer"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLivraisons = _getFilteredLivraisons();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique des bons de livraison',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _chargerHistorique,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLivraisons.length,
              itemBuilder: (context, index) {
                final livraison = filteredLivraisons[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _afficherDetails(livraison),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                livraison['reference'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(livraison['statut']).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  livraison['statut'],
                                  style: TextStyle(
                                    color: _getStatusColor(livraison['statut']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Client: ${livraison['client']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Date: ${livraison['date']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${currencyFormat.format(livraison['total'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                                    onPressed: () => _genererPDF(livraison),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _modifierLivraison(livraison),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: const Color.fromARGB(255, 86, 244, 54)),
                                    onPressed: () => _supprimerLivraison(index),
                                  ),
                                ],
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
        onPressed: _creerNouvelleLivraison,
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}