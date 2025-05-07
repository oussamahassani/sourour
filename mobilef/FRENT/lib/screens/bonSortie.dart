import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class BonSortiePage extends StatefulWidget {
  @override
  _BonSortiePageState createState() => _BonSortiePageState();
}

class _BonSortiePageState extends State<BonSortiePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? _nomResponsable;
  String? _service;
  String? _description;
  String? _typeMateriel;
  DateTime? _dateSortie;
  String? _selectedClient;
  String? _selectedArticle;
  
  // Data for items table
  List<Map<String, dynamic>> _items = [
    {'article': '', 'quantite': ''}
  ];

  // Sample data (replace with your database queries)
  List<String> _clients = ['Client 1', 'Client 2', 'Client 3', 'Client 4'];
  List<String> _articles = ['Article 1', 'Article 2', 'Article 3', 'Article 4'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateSortie)
      setState(() {
        _dateSortie = picked;
      });
  }

  void _addItem() {
    if (_selectedArticle != null) {
      setState(() {
        _items.add({
          'article': _selectedArticle,
          'quantite': ''
        });
        _selectedArticle = null;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      if (_items.length > 1) {
        _items.removeAt(index);
      }
    });
  }

  void _navigateToHistorique() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoriquePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Bon de Sortie'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12.0 : 20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Formulaire de Bon de Sortie',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToHistorique,
                          icon: Icon(Icons.history),
                          label: Text('Historique'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    
                    // Informations générales
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations Générales',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          isSmallScreen
                          ? Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nom du Responsable',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  ),
                                  onSaved: (value) {
                                    _nomResponsable = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le nom du responsable';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Service',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.business),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  ),
                                  onSaved: (value) {
                                    _service = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le service';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Nom du Responsable',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                    onSaved: (value) {
                                      _nomResponsable = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le nom du responsable';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Service',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.business),
                                    ),
                                    onSaved: (value) {
                                      _service = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le service';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    
                    // Détails du matériel
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Détails du Matériel',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: isSmallScreen ? 10 : 15),
                            ),
                            maxLines: 2,
                            onSaved: (value) {
                              _description = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une description';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          isSmallScreen
                          ? Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Type de Matériel',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.category),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  ),
                                  onSaved: (value) {
                                    _typeMateriel = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le type de matériel';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Date de Sortie',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    ),
                                    child: Text(
                                      _dateSortie == null
                                          ? 'Choisir une date'
                                          : DateFormat('dd/MM/yyyy').format(_dateSortie!),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Type de Matériel',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.category),
                                    ),
                                    onSaved: (value) {
                                      _typeMateriel = value;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Veuillez entrer le type de matériel';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date de Sortie',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        _dateSortie == null
                                            ? 'Choisir une date'
                                            : DateFormat('dd/MM/yyyy').format(_dateSortie!),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    
                    // Sélection du client
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _selectedClient,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            hint: Text('Sélectionner un client'),
                            items: _clients.map((client) {
                              return DropdownMenuItem<String>(
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
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    
                    // Liste des articles
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Liste des Articles',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Sélection d'article
                          DropdownButtonFormField<String>(
                            value: _selectedArticle,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              labelText: 'Sélectionner un article',
                            ),
                            items: _articles.map((article) {
                              return DropdownMenuItem<String>(
                                value: article,
                                child: Text(article),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedArticle = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: Icon(Icons.add, size: isSmallScreen ? 16 : 24),
                            label: Text('Ajouter l\'article', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 16,
                                vertical: isSmallScreen ? 4 : 8,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          for (int i = 0; i < _items.length; i++) ...[
                            if (i > 0) SizedBox(height: 10),
                            isSmallScreen 
                            ? Column(
                                children: [
                                  Text(
                                    _items[i]['article'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Quantité',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(() {
                                              _items[i]['quantite'] = value;
                                            });
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.teal, size: 20),
                                        constraints: BoxConstraints(),
                                        padding: EdgeInsets.all(8),
                                        onPressed: () => _removeItem(i),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      _items[i]['article'],
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Quantité',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          _items[i]['quantite'] = value;
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.teal),
                                    onPressed: () => _removeItem(i),
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    
                    // Actions
                    isSmallScreen
                    ? Column(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: Text('Enregistrer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 45),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bon de sortie enregistré avec succès'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.save),
                            label: Text('Enregistrer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Bon de sortie enregistré avec succès'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    
                    SizedBox(height: isSmallScreen ? 10 : 20),
                    
                    // Note informative
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade800),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Veuillez vérifier toutes les informations avant d\'enregistrer le bon de sortie.',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.blue.shade800,
                              ),
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
        ),
      ),
    );
  }
}

class HistoriquePage extends StatefulWidget {
  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  List<BonSortie> _bonsSortie = [];
  List<BonSortie> _filteredBons = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterBons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _bonsSortie = List.generate(
          15,
          (index) => BonSortie(
            id: 'BS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 12)}',
            date: DateTime.now().subtract(Duration(days: index)),
            responsable: 'Responsable ${index + 1}',
            service: 'Service ${['RH', 'IT', 'Finance', 'Logistique'][index % 4]}',
            description: 'Matériel sorti pour ${['maintenance', 'réparation', 'remplacement', 'projet'][index % 4]}',
            typeMateriel: ['Ordinateur', 'Imprimante', 'Mobilier', 'Autre'][index % 4],
            client: 'Client ${index % 4 + 1}',
            items: List.generate(
              (index % 3) + 1,
              (itemIndex) => Item(
                nomArticle: 'Article ${itemIndex + 1}',
                quantite: (itemIndex + 1) * 2,
              ),
            ),
          ),
        );
        _filteredBons = _bonsSortie;
        _isLoading = false;
      });
    });
  }

  void _filterBons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBons = _bonsSortie.where((bon) {
        return bon.id.toLowerCase().contains(query) ||
            bon.responsable.toLowerCase().contains(query) ||
            bon.service.toLowerCase().contains(query) ||
            bon.typeMateriel.toLowerCase().contains(query) ||
            bon.description.toLowerCase().contains(query) ||
            bon.client.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _genererPDF(BonSortie bon) async {
    try {
      final PdfColor tealColor = PdfColor.fromHex('#008080');
      final PdfColor whiteColor = PdfColors.white;
      final PdfColor blackColor = PdfColors.black;
      final PdfColor lightTealColor = PdfColor.fromHex('#E0F2F1');

      final ByteData logoData = await rootBundle.load('images/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');

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
                      child: pw.Image(logoImage),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Adresse: Rue dela nouvelle Delhi, Belvédére Tunis',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text('Tél: 9230991', style: pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          'Email: contact@esprit-climatique.tn',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Matricule fiscale: 1883626X/A/M/000',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                
                pw.Divider(thickness: 2, color: tealColor),
                pw.SizedBox(height: 20),
                
                pw.Center(
                  child: pw.Text(
                    'BON DE SORTIE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24,
                      color: tealColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                
                pw.Container(
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: tealColor),
                    borderRadius: pw.BorderRadius.circular(5),
                    color: lightTealColor,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('INFORMATIONS DU BON',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                              color: tealColor)),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text('Numéro: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(bon.id, style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text('Date de sortie: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(dateFormat.format(bon.date), style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text('Responsable: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(bon.responsable, style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text('Service: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(bon.service, style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text('Client: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(bon.client, style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Description: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Expanded(
                            child: pw.Text(bon.description, 
                                style: pw.TextStyle(color: blackColor)),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Text('Type de matériel: ',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: blackColor)),
                          pw.Text(bon.typeMateriel, style: pw.TextStyle(color: blackColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                
                pw.Text(
                  'Matériels sortis',
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
                    2: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: tealColor,
                        borderRadius: pw.BorderRadius.vertical(
                            top: pw.Radius.circular(5)),
                      ),
                      children: [
                        _headerCell('Article'),
                        _headerCell('Quantité'),
                        _headerCell('Signature'),
                      ],
                    ),
                    for (var item in bon.items)
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: bon.items.indexOf(item) % 2 == 0 
                              ? whiteColor 
                              : lightTealColor,
                          border: pw.Border(
                            bottom: pw.BorderSide(color: tealColor, width: 1),
                          ),
                        ),
                        children: [
                          _dataCell(item.nomArticle, textColor: Colors.black),
                          _dataCell(item.quantite.toString(), textColor: Colors.black),
                          _dataCell('', textColor: Colors.black),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 40),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Responsable du service',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, color: tealColor)),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 200,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: tealColor)
                            )
                          ),
                          child: pw.Text(bon.responsable,
                              style: pw.TextStyle(
                                  decoration: pw.TextDecoration.underline,
                                  color: blackColor)),
                        ),
                        pw.Text('(Signature et cachet)',
                            style: pw.TextStyle(
                                fontStyle: pw.FontStyle.italic, 
                                fontSize: 10, 
                                color: blackColor)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Responsable du stock',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, color: tealColor)),
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
                            style: pw.TextStyle(
                                fontStyle: pw.FontStyle.italic, 
                                fontSize: 10, 
                                color: blackColor)),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                pw.Footer(
                  margin: pw.EdgeInsets.only(top: 10),
                  trailing: pw.Text(
                    'Page ${context.pageNumber} sur ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 10, color: tealColor),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
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

  pw.Container _headerCell(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Container _dataCell(String text, {Color textColor = Colors.black}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColor.fromInt(textColor.value),
        ),
      ),
    );
  }

  void _supprimerBon(int index) {
    final bonToDelete = _filteredBons[index];
    setState(() {
      _bonsSortie.removeWhere((bon) => bon.id == bonToDelete.id);
      _filteredBons.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bon de sortie supprimé'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _bonsSortie.insert(index, bonToDelete);
              _filterBons();
            });
          },
        ),
      ),
    );
  }

  void _afficherDetails(BonSortie bon) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails du bon de sortie', style: TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Numéro', bon.id),
                _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(bon.date)),
                _buildDetailRow('Responsable', bon.responsable),
                _buildDetailRow('Service', bon.service),
                _buildDetailRow('Client', bon.client),
                _buildDetailRow('Description', bon.description),
                _buildDetailRow('Type Matériel', bon.typeMateriel),
                SizedBox(height: 16),
                Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                ...bon.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Article', item.nomArticle),
                      _buildDetailRow('Quantité', item.quantite.toString()),
                      Divider(),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () => _genererPDF(bon),
              child: Text('Générer PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Bons de Sortie'),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          prefixIcon: Icon(Icons.search, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : _filteredBons.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucun bon de sortie trouvé',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              if (_searchController.text.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterBons();
                                  },
                                  child: Text('Réinitialiser la recherche'),
                                ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _loadData(),
                          color: Colors.teal,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 16),
                            itemCount: _filteredBons.length,
                            itemBuilder: (context, index) {
                              final bon = _filteredBons[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _afficherDetails(bon),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              bon.id,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.teal,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('dd/MM/yyyy').format(bon.date),
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          
                                            
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          bon.responsable,
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(bon.service),
                                              backgroundColor: Colors.teal.shade50,
                                              labelStyle: TextStyle(color: Colors.teal),
                                            ),
                                            SizedBox(width: 8),
                                            Chip(
                                              label: Text(bon.typeMateriel),
                                              backgroundColor: Colors.blue.shade50,
                                              labelStyle: TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                                              onPressed: () => _genererPDF(bon),
                                              tooltip: 'Générer PDF',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red.shade300),
                                              onPressed: () => _supprimerBon(index),
                                              tooltip: 'Supprimer',
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
            ),
          ],
        ),
      ),
    );
  }
}

class BonSortie {
  final String id;
  final DateTime date;
  final String responsable;
  final String service;
  final String description;
  final String typeMateriel;
  final List<Item> items;

  BonSortie({
    required this.id,
    required this.date,
    required this.responsable,
    required this.service,
    required this.description,
    required this.typeMateriel,
    required this.items, required String client,
  });
  
  String get client => 'null';
}

class Item {
  final String nomArticle;
  final int quantite;

  Item({
    required this.nomArticle,
    required this.quantite,
  });
}

void main() {
  runApp(MaterialApp(
    title: 'Gestion des Bons de Sortie',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: BonSortiePage(),
    debugShowCheckedModeBanner: false,
  ));
}