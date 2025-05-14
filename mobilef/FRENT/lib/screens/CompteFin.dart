import 'package:flutter/material.dart';

// Main App Theme and Structure
class ComptaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Comptable',
      theme: ThemeData(
        // Teal-based color scheme
        primarySwatch: Colors.teal,
        primaryColor: Color(0xFF009688), // Teal primary
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF009688),
          secondary: Color(0xFF26A69A), // Teal light
          tertiary: Color(0xFF004D40), // Teal dark
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        // Input field styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF26A69A)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        // Button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF26A69A),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Card styling
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      home: CompteList(), // Set CompteList as the home screen
      debugShowCheckedModeBanner: false,
    );
  }
}

// Account Form
class CompteForm extends StatefulWidget {
  final Map<String, dynamic>? compteToEdit;

  CompteForm({this.compteToEdit});

  @override
  _CompteFormState createState() => _CompteFormState();
}

class _CompteFormState extends State<CompteForm> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _banqueController = TextEditingController();
  final TextEditingController _deviseController = TextEditingController();
  final TextEditingController _ribController = TextEditingController();
  final TextEditingController _soldeInitialController = TextEditingController();
  
  String _typeCompte = 'Banque';
  List<String> _typesCompte = ['Banque', 'Caisse', 'Portefeuille', 'Placement', 'Autre'];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _deviseController.text = 'TND';
    _soldeInitialController.text = '0.00';
    
    if (widget.compteToEdit != null) {
      _isEditing = true;
      _nomController.text = widget.compteToEdit!['nom_compte'];
      _typeCompte = widget.compteToEdit!['type_compte'];
      _numeroController.text = widget.compteToEdit!['numero_compte'] ?? '';
      _banqueController.text = widget.compteToEdit!['banque'] ?? '';
      _deviseController.text = widget.compteToEdit!['devise'];
      _ribController.text = widget.compteToEdit!['rib'].toString();
      _soldeInitialController.text = widget.compteToEdit!['solde'].toString();
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    _banqueController.dispose();
    _deviseController.dispose();
    _ribController.dispose();
    _soldeInitialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le compte' : 'Ajouter un compte'),
         backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section informations générales
              _buildSectionTitle('Informations générales'),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du compte',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nom pour ce compte';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _typeCompte,
                decoration: InputDecoration(
                  labelText: 'Type de compte',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _typesCompte
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _typeCompte = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _soldeInitialController,
                decoration: InputDecoration(
                  labelText: 'Solde initial',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un solde initial';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Veuillez saisir un montant valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _deviseController,
                decoration: InputDecoration(
                  labelText: 'Devise',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une devise';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 32),
              // Section informations bancaires
              _buildSectionTitle('Informations bancaires'),
              SizedBox(height: 16),
              TextFormField(
                controller: _numeroController,
                decoration: InputDecoration(
                  labelText: 'Numéro de compte',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: 'Facultatif pour les caisses',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _banqueController,
                decoration: InputDecoration(
                  labelText: 'Nom de la banque',
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'Facultatif pour les caisses',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ribController,
                decoration: InputDecoration(
                  labelText: 'RIB',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_typeCompte == 'Banque' && (value == null || value.isEmpty)) {
                    return 'Veuillez saisir un RIB';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCompte,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _isEditing ? 'METTRE À JOUR' : 'ENREGISTRER LE COMPTE',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (!_isEditing)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompteList()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'VOIR LA LISTE DES COMPTES',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Divider(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ],
    );
  }

  void _saveCompte() {
    if (_formKey.currentState!.validate()) {
      // Logique de sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Compte mis à jour avec succès!'
              : 'Compte créé avec succès!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      
      // Retourner à la liste des comptes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompteList()),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation de suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce compte? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ANNULER'),
          ),
          TextButton(
            onPressed: () {
              // Logique de suppression
              Navigator.pop(context); // Fermer la boîte de dialogue
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CompteList()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compte supprimé avec succès!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Account List
class CompteList extends StatefulWidget {
  @override
  _CompteListState createState() => _CompteListState();
}

class _CompteListState extends State<CompteList> {
  List<Map<String, dynamic>> _comptes = [
    {
      'id_compte': 1,
      'nom_compte': 'Compte Principal',
      'type_compte': 'Banque',
      'solde': 15000.00,
      'numero_compte': '123456789',
      'banque': 'BNA',
      'devise': 'TND',
      'rib': 12345678
    },
    {
      'id_compte': 2,
      'nom_compte': 'Caisse',
      'type_compte': 'Caisse',
      'solde': 5000.00,
      'numero_compte': null,
      'banque': null,
      'devise': 'TND',
      'rib': 87654321
    },
    {
      'id_compte': 3,
      'nom_compte': 'Portefeuille',
      'type_compte': 'Portefeuille',
      'solde': 800.00,
      'numero_compte': null,
      'banque': null,
      'devise': 'TND',
      'rib': 98765432
    },
  ];

  List<Map<String, dynamic>> _filteredComptes = [];
  TextEditingController _searchController = TextEditingController();
  String _currentFilter = 'Tous';
  List<String> _filters = ['Tous', 'Banque', 'Caisse', 'Portefeuille', 'Autre'];

  @override
  void initState() {
    super.initState();
    _filteredComptes = _comptes;
    _searchController.addListener(_filterComptes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterComptes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredComptes = _comptes.where((compte) {
        bool matchesSearch = compte['nom_compte'].toLowerCase().contains(query) ||
            (compte['numero_compte'] != null &&
                compte['numero_compte'].toString().toLowerCase().contains(query));

        bool matchesType =
            _currentFilter == 'Tous' || compte['type_compte'] == _currentFilter;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _applyTypeFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _filterComptes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des comptes'),
         backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte résumé
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total des comptes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_comptes.length} comptes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Solde global',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${_calculateTotalSolde().toStringAsFixed(2)} TND',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un compte...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
           
            ),
          ),

          // Chips de filtrage
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  bool isSelected = _currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        _applyTypeFilter(filter);
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor:
                          Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.secondary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Liste des comptes
          Expanded(
            child: _filteredComptes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun compte trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredComptes.length,
                    padding: EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final compte = _filteredComptes[index];
                      return _buildCompteCard(context, compte);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompteForm()),
          ).then((_) {
            // Rafraîchir la liste après l'ajout
            _filterComptes();
          });
        },
        label: Text('AJOUTER'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  double _calculateTotalSolde() {
    double total = 0;
    for (var compte in _comptes) {
      total += compte['solde'];
    }
    return total;
  }

  Widget _buildCompteCard(BuildContext context, Map<String, dynamic> compte) {
    IconData typeIcon;
    Color typeColor;

    // Définir les couleurs dans la palette teal
    switch (compte['type_compte']) {
      case 'Banque':
        typeIcon = Icons.account_balance;
        typeColor = Theme.of(context).primaryColor; // Teal primary
        break;
      case 'Caisse':
        typeIcon = Icons.point_of_sale;
        typeColor = Color(0xFF4DB6AC); // Teal 300
        break;
      case 'Portefeuille':
        typeIcon = Icons.wallet;
        typeColor = Color(0xFF26A69A); // Teal light
        break;
      default:
        typeIcon = Icons.folder;
        typeColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showCompteActions(context, compte);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compte['nom_compte'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      compte['type_compte'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      compte['banque'] != null
                          ? 'Banque: ${compte['banque']}'
                          : 'Aucune banque',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${compte['solde'].toStringAsFixed(2)} ${compte['devise']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    compte['numero_compte'] != null
                        ? 'N° ${compte['numero_compte']}'
                        : '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompteActions(BuildContext context, Map<String, dynamic> compte) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: Text('Modifier le compte'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompteForm(compteToEdit: compte),
                    ),
                  ).then((_) {
                    // Refresh the list after editing
                    _filterComptes();
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer le compte', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, compte);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: Colors.grey),
                title: Text('Voir les détails'),
                onTap: () {
                  Navigator.pop(context);
                  _showCompteDetails(context, compte);
                },
              ),
              SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ANNULER'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> compte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le compte "${compte['nom_compte']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ANNULER'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _comptes.removeWhere((c) => c['id_compte'] == compte['id_compte']);
                _filterComptes();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compte supprimé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompteDetails(BuildContext context, Map<String, dynamic> compte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails du compte'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Nom du compte', compte['nom_compte']),
              _buildDetailItem('Type de compte', compte['type_compte']),
              _buildDetailItem('Solde', '${compte['solde'].toStringAsFixed(2)} ${compte['devise']}'),
              if (compte['numero_compte'] != null)
                _buildDetailItem('Numéro de compte', compte['numero_compte']),
              if (compte['banque'] != null)
                _buildDetailItem('Banque', compte['banque']),
              _buildDetailItem('RIB', compte['rib'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('FERMER'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filtrer par type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filters.map((filter) {
                  bool isSelected = _currentFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      _applyTypeFilter(filter);
                      Navigator.pop(context);
                    },
                    selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('FERMER'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
