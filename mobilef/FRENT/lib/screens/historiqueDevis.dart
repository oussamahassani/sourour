import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HistoriqueDevisScreen extends StatefulWidget {
  @override
  _HistoriqueDevisScreenState createState() => _HistoriqueDevisScreenState();
}

class _HistoriqueDevisScreenState extends State<HistoriqueDevisScreen> {
  List<Map<String, dynamic>> _allDevis = [];
  List<Map<String, dynamic>> _filteredDevis = [];
  final TextEditingController _searchController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
  String _currentFilter = 'Tous';
  
  get rootBundle => null;

  @override
  void initState() {
    super.initState();
    _loadDevis();
    _searchController.addListener(_filterDevis);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDevis() {
    setState(() {
      _allDevis = [
        {
          'reference': 'DEV-2023-001',
          'client': 'Client 1',
          'date': '15/06/2023',
          'total': 1200.0,
          'statut': 'Accepté',
          'articles': [
            {'nom': 'Produit A', 'quantite': 2, 'prixHT': 100.0},
            {'nom': 'Produit B', 'quantite': 1, 'prixHT': 1000.0},
          ],
          'adresse': '123 Rue des Exemples, 75000 Paris',
          'remise': '0',
          'photo': null,
          'type': 'formulaire',
          'validite': '30 jours',
        },
        {
          'reference': 'DEV-2023-002',
          'client': 'Client 2',
          'date': '20/06/2023',
          'total': 850.0,
          'statut': 'En attente',
          'articles': [
            {'nom': 'Produit B', 'quantite': 3, 'prixHT': 75.0},
            {'nom': 'Accessoire C', 'quantite': 5, 'prixHT': 125.0},
          ],
          'adresse': '456 Avenue des Tests, 69000 Lyon',
          'remise': '5',
          'photo': null,
          'type': 'formulaire',
          'validite': '15 jours',
        },
        {
          'reference': 'DEV-RAP-2023-001',
          'client': 'Client 3',
          'date': '25/06/2023',
          'total': 1500.0,
          'statut': 'Refusé',
          'articles': [],
          'adresse': '789 Boulevard des Démonstrations, 13000 Marseille',
          'remise': '0',
          'photo': 'https://via.placeholder.com/600x400?text=Devis',
          'type': 'photo',
          'validite': '30 jours',
        },
      ];
      _filteredDevis = List.from(_allDevis);
    });
  }

  void _filterDevis() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDevis = _allDevis.where((devis) {
        final matchesSearch = devis['reference'].toLowerCase().contains(query) ||
            devis['client'].toLowerCase().contains(query);
        
        final matchesFilter = _currentFilter == 'Tous' || 
            (_currentFilter == 'Formulaire' && devis['type'] == 'formulaire') ||
            (_currentFilter == 'Photo' && devis['type'] == 'photo');
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _changeFilter(String? newValue) {
    if (newValue != null) {
      setState(() {
        _currentFilter = newValue;
        _filterDevis();
      });
    }
  }

  void _deleteDevis(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer ce devis ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler', style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _allDevis.removeAt(index);
                  _filterDevis();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Devis supprimé avec succès'),
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

  void _editDevis(Map<String, dynamic> devis) {
    if (devis['type'] == 'formulaire') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFormulaireDevisScreen(devis: devis),
        ),
      ).then((value) {
        if (value != null) {
          setState(() {
            _loadDevis();
          });
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPhotoDevisScreen(devis: devis),
        ),
      ).then((value) {
        if (value != null) {
          setState(() {
            _loadDevis();
          });
        }
      });
    }
  }

  void _showDevisDetails(Map<String, dynamic> devis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails du devis', style: TextStyle(color: Colors.teal.shade700)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (devis['type'] == 'photo' && devis['photo'] != null) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: devis['photo'],
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                ],
                _buildDetailItem('Type:', devis['type'] == 'formulaire' ? 'Formulaire' : 'Photo'),
                _buildDetailItem('Référence:', devis['reference']),
                _buildDetailItem('Client:', devis['client']),
                _buildDetailItem('Date:', devis['date']),
                _buildDetailItem('Statut:', devis['statut']),
                _buildDetailItem('Total:', currencyFormat.format(devis['total'])),
                _buildDetailItem('Adresse:', devis['adresse']),
                _buildDetailItem('Validité:', devis['validite']),
                _buildDetailItem('Remise:', '${devis['remise']} €'),
                
                if (devis['type'] == 'formulaire') ...[
                  SizedBox(height: 16),
                  Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ...devis['articles'].map<Widget>((article) => Padding(
                    padding:  EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '- ${article['nom']} (x${article['quantite']}) - ${currencyFormat.format(article['prixHT'])} HT',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )).toList(),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey.shade800))),
        ],
      ),
    );
  }

 

Future<void> _generatePdf(Map<String, dynamic> devis) async {
  try {
    final pdf = pw.Document();
    
    // 1. Chargement du logo avec gestion d'erreur
    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      print("Erreur de chargement du logo: $e");
      // Vous pouvez utiliser une image par défaut ou continuer sans logo
    }
    
    // 2. Vérification des données obligatoires
    if (devis['reference'] == null || devis['date'] == null) {
      throw Exception("Données du devis incomplètes");
    }

    // 3. Styles avec valeurs par défaut sécurisées
    final tealColor = PdfColor.fromInt(0xFF009688);
    final blackColor = PdfColor.fromInt(0xFF000000);
    
    final styles = {
      'header': pw.TextStyle(
        fontSize: 24, 
        fontWeight: pw.FontWeight.bold,
        color: tealColor,
      ),
      'subHeader': pw.TextStyle(
        fontSize: 16, 
        fontWeight: pw.FontWeight.bold,
        color: blackColor,
      ),
      // ... autres styles
    };

    // 4. Format de devise sécurisé
    final currencyFormat = NumberFormat.currency(
      symbol: 'TND ',
      decimalDigits: 3,
      locale: 'fr_TN',
    );

    // 5. Construction du PDF avec vérification des données
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête avec vérification du logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoImage != null) pw.Image(logoImage!, height: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('VOTRE ENTREPRISE', style: styles['subHeader']),
                      // ... autres informations
                    ],
                  ),
                ],
              ),
              
              // ... reste du contenu avec vérifications
              _buildDevisInfo(devis, styles, currencyFormat),
              _buildClientInfo(devis, styles),
              
              // Contenu conditionnel avec vérification
              if (devis['type'] == 'formulaire' && devis['articles'] != null)
                _buildArticlesTable(devis, styles, currencyFormat)
              else if (devis['photo'] != null)
                _buildPhotoSection(devis, styles),
                
              _buildFinancialSummary(devis, styles, currencyFormat),
              _buildFooter(devis, styles),
            ],
          );
        },
      ),
    );

    // 6. Sauvegarde avec gestion d'erreur
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/devis_${devis['reference']}.pdf';
    final file = File(path);
    
    await file.writeAsBytes(await pdf.save());
    
    // 7. Ouverture du fichier avec vérification
    final openResult = await OpenFile.open(path);
    if (openResult.type != ResultType.done) {
      print("Erreur d'ouverture: ${openResult.message}");
    }
    
  } catch (e, stack) {
    print("Erreur génération PDF: $e\n$stack");
    // Gérer l'erreur (afficher un message à l'utilisateur, etc.)
    rethrow;
  }
}

// Fonctions helper pour modulariser le code
pw.Widget _buildDevisInfo(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles, NumberFormat currencyFormat) {
  return pw.Container(
    // ... implémentation
  );
}

pw.Widget _buildClientInfo(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles) {
  return pw.Container(
    // ... implémentation
  );
}

pw.Widget _buildArticlesTable(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles, NumberFormat currencyFormat) {
  return pw.Container(
    // ... implémentation avec vérification des articles
    child: pw.Column(
      children: [
        // En-tête du tableau
        pw.Container(
          color: PdfColor.fromInt(0xFF009688),
          child: pw.Row(/* ... */),
        ),
        // Articles
        ...(devis['articles'] as List).map((article) {
          // Vérification des champs requis
          final qte = article['quantite'] ?? 0;
          final prix = article['prixHT'] ?? 0.0;
          final total = qte * prix;
          
          return pw.Row(/* ... */);
        }).toList(),
      ],
    ),
  );
}
   

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepté':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      case 'Refusé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDevisCard(Map<String, dynamic> devis, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
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
                Expanded(
                  child: Text(
                    devis['reference'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    devis['type'] == 'formulaire' ? 'Formulaire' : 'Photo',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: devis['type'] == 'formulaire' ? Colors.blueGrey : Colors.purple,
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
                    devis['client'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    devis['statut'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(devis['statut']),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (devis['type'] == 'photo' && devis['photo'] != null) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: devis['photo'],
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${devis['date']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  'Validité: ${devis['validite']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Total: ${currencyFormat.format(devis['total'])}',
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
                  onPressed: () => _showDevisDetails(devis),
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf, color: Colors.orange),
                  onPressed: () => _generatePdf(devis),
                ),
                if (devis['type'] == 'formulaire') 
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.purple),
                    onPressed: () => _editDevis(devis),
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteDevis(_allDevis.indexOf(devis)),
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
        title: Text('Historique des devis', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Navigation vers l'écran de création de devis
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.teal),
                            onPressed: () {
                              _searchController.clear();
                              _filterDevis();
                            },
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _currentFilter,
                  items: ['Tous', 'Formulaire', 'Photo'].map((String value) {
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
            child: _filteredDevis.isEmpty
                ? Center(
                    child: Text(
                      'Aucun devis trouvé',
                      style: TextStyle(color: Colors.teal, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _filteredDevis.length,
                    itemBuilder: (context, index) {
                      final devis = _filteredDevis[index];
                      return _buildDevisCard(devis, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  getApplicationDocumentsDirectory() {}
  
pw.Widget _buildPhotoSection(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColor.fromInt(0xFF009688)),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
    ),
    child: pw.Column(
      children: [
        pw.Text('DEVIS SCANNÉ', style: styles['subHeader']),
        pw.SizedBox(height: 10),
        pw.Text(
          'Référence: ${devis['reference']}',
          style: styles['bold'],
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          height: 100,
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Photo disponible dans l\'application',
            style: styles['italic'],
          ),
        ),
        if (devis['date'] != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Date: ${devis['date']}',
              style: styles['normal'],
            ),
          ),
      ],
    ),
  );
}  
  _buildFinancialSummary(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles, NumberFormat currencyFormat) {}
  
  _buildFooter(Map<String, dynamic> devis, Map<String, pw.TextStyle> styles) {}
}

// Écrans d'édition fictifs pour les devis
class EditFormulaireDevisScreen extends StatelessWidget {
  final Map<String, dynamic> devis;

  const EditFormulaireDevisScreen({Key? key, required this.devis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier devis formulaire'),
      ),
      body: Center(
        child: Text('Écran de modification pour devis formulaire'),
      ),
    );
  }
}

class EditPhotoDevisScreen extends StatelessWidget {
  final Map<String, dynamic> devis;

  const EditPhotoDevisScreen({Key? key, required this.devis}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier devis photo'),
      ),
      body: Center(
        child: Text('Écran de modification pour devis photo'),
      ),
    );
  }
}