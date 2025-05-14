import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/facture.dart';
import '../services/FactureService.dart';

// Page principale - Historique des factures
class FactureHistoriquePage1 extends StatefulWidget {
  @override
  _FactureHistoriquePageState createState() => _FactureHistoriquePageState();
}

class _FactureHistoriquePageState extends State<FactureHistoriquePage1> {
  List<FactureVente> _factures = [];
  
  @override
  void initState() {
    super.initState();
    _factures = FactureService.getFacturesVente();
  }

  void _rafraichirFactures() {
    setState(() {
      _factures = FactureService.getFacturesVente();
    });
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
        title: Text('Historique des Factures de Vente'),
        elevation: 2,
      ),
      body: _factures.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.blue.shade200),
                  SizedBox(height: 20),
                  Text(
                    'Aucune facture de vente enregistrée',
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
                          builder: (context) => FactureVenteForm(
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
                    color: Colors.blue.shade50,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gestion des Factures de Vente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Consultez, créez, modifiez vos factures et générez des PDF en quelques clics.',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
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
                                builder: (context) => FactureDetailPage(
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
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.receipt, color: Colors.white),
                                ),
                                title: Text(
                                  facture.numeroFacture,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(facture.client),
                                trailing: Chip(
                                  label: Text(
                                    facture.statut,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getStatutColor(facture.statut),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Échéance: ${DateFormat('dd/MM/yyyy').format(facture.dateEcheance)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      '${facture.prixTTC.toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade700,
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
                                            builder: (context) => FactureVenteForm(
                                              facture: facture,
                                              onFactureAdded: _rafraichirFactures,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: Icon(Icons.picture_as_pdf, size: 18),
                                      label: Text('PDF'),
                                      onPressed: () async {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Génération du PDF...')),
                                        );
                                        
                                        final pdfPath = await FactureService.genererPDF(facture);
                                        
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('PDF généré avec succès')),
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
              builder: (context) => FactureVenteForm(
                onFactureAdded: _rafraichirFactures,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Nouvelle facture de vente',
      ),
    );
  }
}

// Page de détail d'une facture
class FactureDetailPage extends StatelessWidget {
  final FactureVente facture;
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
                  builder: (context) => FactureVenteForm(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Génération du PDF...')),
              );
              
              final pdfPath = await FactureService.genererPDF(facture);
              
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF généré avec succès')),
              );
              
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
                            color: Colors.blue.shade700,
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
                    _infoRow('Client', facture.client),
                    _infoRow('Produit', facture.produit),
                    _infoRow('Date de création', 
                      DateFormat('dd/MM/yyyy').format(facture.dateCreation)),
                    _infoRow('Date d\'échéance', 
                      DateFormat('dd/MM/yyyy').format(facture.dateEcheance)),
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
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    _infoRow('Prix HT', '${facture.prixHT.toStringAsFixed(2)} €'),
                    _infoRow('TVA', '${facture.tva.toStringAsFixed(2)} %'),
                    _infoRow('Montant TVA', 
                      '${(facture.prixTTC - facture.prixHT).toStringAsFixed(2)} €'),
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
                            color: Colors.blue.shade800,
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
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          context,
                          'Modifier',
                          Icons.edit,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FactureVenteForm(
                                  facture: facture,
                                  onFactureAdded: onFactureUpdated,
                                ),
                              ),
                            );
                          },
                        ),
                        _actionButton(
                          context,
                          'Générer PDF',
                          Icons.picture_as_pdf,
                          () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Génération du PDF...')),
                            );
                            
                            final pdfPath = await FactureService.genererPDF(facture);
                            
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('PDF généré avec succès')),
                            );
                            
                            OpenFile.open(pdfPath);
                          },
                        ),
                        _actionButton(
                          context,
                          'Partager',
                          Icons.share,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
                            );
                          },
                        ),
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
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue.shade800, backgroundColor: Colors.blue.shade50,
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

// Formulaire de facture de vente
class FactureVenteForm extends StatefulWidget {
  final FactureVente? facture;
  final Function onFactureAdded;

  const FactureVenteForm({
    Key? key,
    this.facture,
    required this.onFactureAdded,
  }) : super(key: key);

  @override
  _FactureVenteFormState createState() => _FactureVenteFormState();
}

class _FactureVenteFormState extends State<FactureVenteForm> {
  final _formKey = GlobalKey<FormState>();
  final _numeroFactureController = TextEditingController();
  final _prixHTController = TextEditingController();
  final _tvaController = TextEditingController();
  final _prixTTCController = TextEditingController();
  
  DateTime? _dateEcheance;
  String? _selectedClient;
  String? _selectedProduit;
  String? _selectedStatut;
  String? _selectedCreateur;
  
  // Liste de données pour les dropdowns
  final List<String> _clients = ['Client 1', 'Client 2', 'Client 3', 'Client 4', 'Client 5'];
  final List<String> _produits = ['Produit A', 'Produit B', 'Produit C', 'Produit D', 'Produit E'];
  final List<String> _statuts = ['Émise', 'Payée', 'En retard', 'Annulée'];
  final List<String> _createurs = ['User 1', 'User 2', 'User 3'];
  
  @override
  void initState() {
    super.initState();
    
    // Si on modifie une facture existante, on initialise les valeurs
    if (widget.facture != null) {
      _numeroFactureController.text = widget.facture!.numeroFacture;
      _selectedClient = widget.facture!.client;
      _selectedProduit = widget.facture!.produit;
      _prixHTController.text = widget.facture!.prixHT.toString();
      _tvaController.text = widget.facture!.tva.toString();
      _prixTTCController.text = widget.facture!.prixTTC.toString();
      _selectedStatut = widget.facture!.statut;
      _dateEcheance = widget.facture!.dateEcheance;
      _selectedCreateur = widget.facture!.createur;
    } else {
      // Valeurs par défaut pour une nouvelle facture
      _numeroFactureController.text = 'FV-${DateTime.now().year}-${_genererNumeroAleatoire()}';
      _tvaController.text = '20.0'; // 20% par défaut
      _dateEcheance = DateTime.now().add(Duration(days: 30)); // 30 jours par défaut
      _selectedStatut = 'Émise';
      _selectedCreateur = 'User 1'; // Par défaut
    }
    
    // Écouter les changements pour calculer le TTC
    _prixHTController.addListener(_calculerPrixTTC);
    _tvaController.addListener(_calculerPrixTTC);
  }
  
  String _genererNumeroAleatoire() {
    // Génère un numéro à 3 chiffres avec des zéros en préfixe si nécessaire
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    return random.toString().padLeft(3, '0');
  }
  
  void _calculerPrixTTC() {
    if (_prixHTController.text.isNotEmpty && _tvaController.text.isNotEmpty) {
      try {
        final prixHT = double.parse(_prixHTController.text);
        final tva = double.parse(_tvaController.text);
        final prixTTC = prixHT * (1 + tva / 100);
        _prixTTCController.text = prixTTC.toStringAsFixed(2);
      } catch (e) {
        // Gérer les erreurs de conversion
        _prixTTCController.text = '';
      }
    } else {
      _prixTTCController.text = '';
    }
  }
  
  void _sauvegarderFacture() {
    if (_formKey.currentState!.validate()) {
      final double prixHT = double.parse(_prixHTController.text);
      final double tva = double.parse(_tvaController.text);
      final double prixTTC = double.parse(_prixTTCController.text);
      
      if (widget.facture == null) {
        // Créer une nouvelle facture
        final nouvelleFacture = FactureVente(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          numeroFacture: _numeroFactureController.text,
          client: _selectedClient!,
          produit: _selectedProduit!,
          prixHT: prixHT,
          tva: tva,
          prixTTC: prixTTC,
          statut: _selectedStatut!,
          dateCreation: DateTime.now(),
          dateEcheance: _dateEcheance!,
          createur: _selectedCreateur!,
        );
        
        FactureService.ajouterFactureVente(nouvelleFacture);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facture créée avec succès')),
        );
      } else {
        // Mettre à jour une facture existante
        final factureModifiee = widget.facture!.copyWith(
          numeroFacture: _numeroFactureController.text,
          client: _selectedClient,
          produit: _selectedProduit,
          prixHT: prixHT,
          tva: tva,
          prixTTC: prixTTC,
          statut: _selectedStatut,
          dateEcheance: _dateEcheance,
          createur: _selectedCreateur,
        );
        
        FactureService.mettreAJourFactureVente(factureModifiee);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facture mise à jour avec succès')),
        );
      }
      
      // Rappeler la fonction de mise à jour et revenir en arrière
      widget.onFactureAdded();
      Navigator.pop(context);
    }
  }
  
  @override
  void dispose() {
    _numeroFactureController.dispose();
    _prixHTController.dispose();
    _tvaController.dispose();
    _prixTTCController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facture == null ? 'Nouvelle Facture' : 'Modifier Facture'),
        actions: [
          TextButton(
            child: Text(
              'ENREGISTRER',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: _sauvegarderFacture,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations générales
              Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations générales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _numeroFactureController,
                        decoration: InputDecoration(
                          labelText: 'Numéro de facture',
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un numéro de facture';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedClient,
                        decoration: InputDecoration(
                          labelText: 'Client',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _clients.map((client) {
                          return DropdownMenuItem(
                            value: client,
                            child: Text(client),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClient = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un client';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedProduit,
                        decoration: InputDecoration(
                          labelText: 'Produit',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        items: _produits.map((produit) {
                          return DropdownMenuItem(
                            value: produit,
                            child: Text(produit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProduit = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un produit';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Informations financières
              Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations financières',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _prixHTController,
                        decoration: InputDecoration(
                          labelText: 'Prix HT (€)',
                          prefixIcon: Icon(Icons.euro),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prix HT';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'Format de nombre invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _tvaController,
                        decoration: InputDecoration(
                          labelText: 'TVA (%)',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un taux de TVA';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'Format de nombre invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _prixTTCController,
                        decoration: InputDecoration(
                          labelText: 'Prix TTC (€)',
                          prefixIcon: Icon(Icons.euro),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        readOnly: true,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Statut et dates
              Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut et dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatut,
                        decoration: InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.pending_actions),
                        ),
                        items: _statuts.map((statut) {
                          return DropdownMenuItem(
                            value: statut,
                            child: Text(statut),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatut = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un statut';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Date d\'échéance'),
                        subtitle: Text(
                          _dateEcheance != null
                              ? DateFormat('dd/MM/yyyy').format(_dateEcheance!)
                              : 'Non définie',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dateEcheance ?? DateTime.now().add(Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _dateEcheance = date;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCreateur,
                        decoration: InputDecoration(
                          labelText: 'Créateur',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _createurs.map((createur) {
                          return DropdownMenuItem(
                            value: createur,
                            child: Text(createur),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCreateur = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un créateur';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bouton de validation
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: _sauvegarderFacture,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.facture == null ? 'CRÉER LA FACTURE' : 'METTRE À JOUR LA FACTURE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
