import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/facture.dart';
import '../services/FactureService.dart';
import '../services/article_service.dart';
import '../services/achat_service.dart';
import '../services/user_rh_service.dart';
import '../models/User.dart';
import '../models/article.dart';

// Page principale - Historique des factures
class FactureHistoriquePage extends StatefulWidget {
  @override
  _FactureHistoriquePageState createState() => _FactureHistoriquePageState();
}

class _FactureHistoriquePageState extends State<FactureHistoriquePage> {
  List<FactureAchat> _factures = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    // _factures = FactureService.getFacturesAchat();
  }

  Future<void> _loadData() async {
    final fournisseurService = FactureService();
    final facturesChargees = await fournisseurService.fetchFacturesVenteAchat();
    setState(() {
      _factures = facturesChargees;
    });
  }

  void _rafraichirFactures() {
    _loadData();
    /* setState(() {
      _factures = FactureService.getFacturesAchat();
    });*/
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payée':
        return Colors.green;
      case 'émise':
        return Colors.blue;
      case 'en retard':
        return Colors.red;
      case 'annulée':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Factures d\'Achat'),
        elevation: 2,
      ),
      body:
          _factures.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.teal.shade200,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Aucune facture d\'achat enregistrée',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('Créer une nouvelle facture'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FactureAchatForm(
                                  onFactureAdded: _rafraichirFactures,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.teal.shade50,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.teal),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gestion des Factures d\'Achat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Consultez, créez, modifiez vos factures et générez des PDF en quelques clics.',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _factures.length,
                      itemBuilder: (context, index) {
                        final facture = _factures[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FactureDetailPage(
                                        facture: facture,
                                        onFactureUpdated: _rafraichirFactures,
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    child: Icon(
                                      Icons.receipt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    facture.numeroFacture,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(facture.fournisseur ?? ""),
                                  trailing: Chip(
                                    label: Text(
                                      facture.statut,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: _getStatutColor(
                                      facture.statut,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Échéance: ${DateFormat('dd/MM/yyyy').format(facture.dateEcheance)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${facture.prixTTC.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: Icon(Icons.edit, size: 18),
                                        label: Text('Modifier'),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => FactureAchatForm(
                                                    facture: facture,
                                                    onFactureAdded:
                                                        _rafraichirFactures,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 8),
                                      TextButton.icon(
                                        icon: Icon(
                                          Icons.picture_as_pdf,
                                          size: 18,
                                        ),
                                        label: Text('PDF'),
                                        onPressed: () async {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Génération du PDF...',
                                              ),
                                            ),
                                          );

                                          final pdfPath =
                                              await FactureService.genererPDF(
                                                facture,
                                              );

                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'PDF généré avec succès',
                                              ),
                                            ),
                                          );

                                          OpenFile.open(pdfPath);
                                        },
                                      ),
                                    ],
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FactureAchatForm(onFactureAdded: _rafraichirFactures),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Nouvelle facture d\'achat',
      ),
    );
  }
}

// Page de détail d'une facture
class FactureDetailPage extends StatelessWidget {
  final FactureAchat facture;
  final Function onFactureUpdated;

  const FactureDetailPage({
    Key? key,
    required this.facture,
    required this.onFactureUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Facture'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FactureAchatForm(
                        facture: facture,
                        onFactureAdded: onFactureUpdated,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Génération du PDF...')));

              final pdfPath = await FactureService.genererPDF(facture);

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('PDF généré avec succès')));

              OpenFile.open(pdfPath);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la facture
            Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Facture ${facture.numeroFacture}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        Chip(
                          label: Text(
                            facture.statut,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatutColor(facture.statut),
                        ),
                      ],
                    ),
                    Divider(height: 32),
                    _infoRow('Fournisseur', facture.fournisseur ?? ""),
                    _infoRow('Produit', facture.produit ?? ""),
                    _infoRow(
                      'Date de création',
                      DateFormat('dd/MM/yyyy').format(facture.dateCreation),
                    ),
                    _infoRow(
                      'Date d\'échéance',
                      DateFormat('dd/MM/yyyy').format(facture.dateEcheance),
                    ),
                    _infoRow('Créé par', facture.createur),
                  ],
                ),
              ),
            ),

            // Détails financiers
            Card(
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails Financiers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    _infoRow(
                      'Prix HT',
                      '${facture.prixHT.toStringAsFixed(2)} €',
                    ),
                    _infoRow('TVA', '${facture.tva.toStringAsFixed(2)} %'),
                    _infoRow(
                      'Montant TVA',
                      '${(facture.prixTTC - facture.prixHT).toStringAsFixed(2)} €',
                    ),
                    Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total TTC',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${facture.prixTTC.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(context, 'Modifier', Icons.edit, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FactureAchatForm(
                                    facture: facture,
                                    onFactureAdded: onFactureUpdated,
                                  ),
                            ),
                          );
                        }),
                        _actionButton(
                          context,
                          'Générer PDF',
                          Icons.picture_as_pdf,
                          () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Génération du PDF...')),
                            );

                            final pdfPath = await FactureService.genererPDF(
                              facture,
                            );

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('PDF généré avec succès')),
                            );

                            OpenFile.open(pdfPath);
                          },
                        ),
                        _actionButton(context, 'Partager', Icons.share, () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fonctionnalité de partage à implémenter',
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.teal.shade800,
            backgroundColor: Colors.teal.shade50,
            shape: CircleBorder(),
            padding: EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'payée':
        return Colors.green;
      case 'émise':
        return Colors.blue;
      case 'en retard':
        return Colors.red;
      case 'annulée':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

// Formulaire de facture d'achat
class FactureAchatForm extends StatefulWidget {
  final FactureAchat? facture;
  final Function onFactureAdded;

  const FactureAchatForm({Key? key, this.facture, required this.onFactureAdded})
    : super(key: key);

  @override
  _FactureAchatFormState createState() => _FactureAchatFormState();
}

class _FactureAchatFormState extends State<FactureAchatForm> {
  final _formKey = GlobalKey<FormState>();
  final _numeroFactureController = TextEditingController();
  final _prixHTController = TextEditingController();
  final _tvaController = TextEditingController();
  final _prixTTCController = TextEditingController();

  DateTime? _dateEcheance;
  String? _selectedFournisseur;
  String? _selectedProduit;
  String? _selectedCreateur;
  String _selectedStatut = 'Brouillon';

  List<Map<String, String>> _fournisseurs = [];
  List<Article> _produits = [];
  List<User> _createurs = [];
  List<String> _statuts = [
    'Brouillon',
    'Émise',
    'Payée',
    'Annulée',
    'En retard',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.facture != null) {
      // Mode édition - pré-remplir les champs
      final facture = widget.facture!;
      _numeroFactureController.text = facture.numeroFacture;
      _selectedFournisseur = facture.fournisseur;
      _selectedProduit = facture.produit;
      _prixHTController.text = facture.prixHT.toStringAsFixed(2);
      _tvaController.text = facture.tva.toStringAsFixed(2);
      _prixTTCController.text = facture.prixTTC.toStringAsFixed(2);
      _selectedStatut = facture.statut;
      _dateEcheance = facture.dateEcheance;
      _selectedCreateur = facture.createur;
    } else {
      // Mode création - valeurs par défaut
      _tvaController.text = '20.0';
      _dateEcheance = DateTime.now().add(const Duration(days: 30));
      _selectedCreateur = null;
    }
    _loadData();
  }

  // Appelle une méthode async sans await
  Future<void> _loadData() async {
    final articleService = ArticleService();
    final fournisseurService = PurchaseService();

    _produits = await articleService.fetchAllArticles();
    _fournisseurs = await fournisseurService.getfetchSuppliers();
    _createurs = await UserRhService.fetchALLadmin();
    print(_produits);
  }

  @override
  void dispose() {
    _numeroFactureController.dispose();
    _prixHTController.dispose();
    _tvaController.dispose();
    _prixTTCController.dispose();
    super.dispose();
  }

  void _calculateTTC() {
    if (_prixHTController.text.isNotEmpty && _tvaController.text.isNotEmpty) {
      final prixHT = double.tryParse(_prixHTController.text) ?? 0;
      final tva = double.tryParse(_tvaController.text) ?? 0;
      final prixTTC = prixHT * (1 + tva / 100);
      _prixTTCController.text = prixTTC.toStringAsFixed(2);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateEcheance ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dateEcheance) {
      setState(() {
        _dateEcheance = picked;
      });
    }
  }

  void _enregistrerFacture() async {
    if (_formKey.currentState!.validate()) {
      final facture = FactureAchat(
        id:
            widget.facture?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        numeroFacture: _numeroFactureController.text,
        fournisseur: _selectedFournisseur!,
        produit: _selectedProduit!,
        prixHT: int.parse(_prixHTController.text),
        tva: int.parse(_tvaController.text),
        prixTTC: int.parse(_prixTTCController.text),
        statut: _selectedStatut,
        dateCreation: widget.facture?.dateCreation ?? DateTime.now(),
        dateEcheance: _dateEcheance!,
        createur: _selectedCreateur!,
      );
      final success = await FactureService().saveFactureAchat(facture);
      widget.onFactureAdded(facture);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.facture == null
              ? 'Nouvelle Facture d\'Achat'
              : 'Modifier Facture',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _enregistrerFacture,
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
              TextFormField(
                controller: _numeroFactureController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de facture',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de facture';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFournisseur,
                decoration: const InputDecoration(
                  labelText: 'Fournisseur',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items:
                    _fournisseurs.map((fournisseur) {
                      return DropdownMenuItem<String>(
                        value: fournisseur['id'],
                        child: Text(fournisseur['name'].toString()),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFournisseur = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un fournisseur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedProduit,
                decoration: const InputDecoration(
                  labelText: 'Article',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                items:
                    _produits.map((article) {
                      print('Article in Dropdown: ${article}');
                      return DropdownMenuItem<String>(
                        value: article.id,
                        child: Text(article.nomArticle),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduit = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner un article';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prixHTController,
                      decoration: const InputDecoration(
                        labelText: 'Prix HT',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: '€',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => _calculateTTC(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix HT';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tvaController,
                      decoration: const InputDecoration(
                        labelText: 'TVA',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.percent),
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) => _calculateTTC(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un taux de TVA';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prixTTCController,
                decoration: const InputDecoration(
                  labelText: 'Prix TTC',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                  suffixText: '€',
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatut,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                items:
                    _statuts.map((statut) {
                      return DropdownMenuItem<String>(
                        value: statut,
                        child: Text(statut),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatut = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCreateur,
                decoration: const InputDecoration(
                  labelText: 'Créé par',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items:
                    _createurs.map((createur) {
                      return DropdownMenuItem<String>(
                        value: createur.id,
                        child: Text(createur.nom),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCreateur = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un créateur';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateEcheance == null
                            ? 'Non sélectionnée'
                            : DateFormat('dd/MM/yyyy').format(_dateEcheance!),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(widget.facture == null ? Icons.add : Icons.save),
                  label: Text(
                    widget.facture == null
                        ? 'Créer la facture'
                        : 'Enregistrer les modifications',
                  ),
                  onPressed: _enregistrerFacture,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
