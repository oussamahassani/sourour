import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/fournisseur.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
//import 'article.dart';
import 'article.dart';
import 'fournisseur/fournisseur.dart';
import 'historiqueAchat.dart';

class AchatDirectMobileScreen extends StatefulWidget {
  final Map<String, dynamic>? commandeToEdit;

  const AchatDirectMobileScreen({Key? key, this.commandeToEdit}) : super(key: key);

  @override
  _BonDeCommandeScreenState createState() => _BonDeCommandeScreenState();
}

class _BonDeCommandeScreenState extends State<AchatDirectMobileScreen> {
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _adresseLivraisonController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController(text: '0');
  final TextEditingController _delaiLivraisonController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedFournisseur;
  bool _isTTC = false;
  List<Map<String, dynamic>> _articles = [];
  double _totalHT = 0.0;
  double _totalCommande = 0.0;
  double _sousTotal = 0.0;
  double _totalTVA = 0.0;

  // Liste de fournisseurs existants
  List<String> _fournisseurs = ['Fournisseur 1', 'Fournisseur 2'];

  // Liste des articles existants avec les prix HT par défaut
  List<Map<String, dynamic>> _listeArticles = [
    {'nom': 'Article 1', 'prixHT': 50.0},
    {'nom': 'Article 2', 'prixHT': 30.0},
    {'nom': 'Article 3', 'prixHT': 20.0},
  ];

  String? _selectedArticle;
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _tvaController = TextEditingController(text: '20.0');

  // Formatter pour les montants
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    
    // Si on est en mode édition, pré-remplir les champs
    if (widget.commandeToEdit != null) {
      _referenceController.text = widget.commandeToEdit!['reference'];
      _selectedDate = widget.commandeToEdit!['date'];
      _responsableController.text = widget.commandeToEdit!['responsable'];
      _adresseLivraisonController.text = widget.commandeToEdit!['adresse'];
      _selectedFournisseur = widget.commandeToEdit!['fournisseur'];
      _articles = List.from(widget.commandeToEdit!['articles']);
      _calculerTotal();
    }
  }

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

  void _enregistrerCommande() {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      final commande = {
        'reference': _referenceController.text,
        'date': _selectedDate,
        'responsable': _responsableController.text,
        'fournisseur': _selectedFournisseur,
        'adresse': _adresseLivraisonController.text,
        'articles': _articles,
        'totalHT': _totalHT,
        'totalTVA': _totalTVA,
        'totalCommande': _totalCommande,
        'remise': double.parse(_remiseController.text),
      };

      // Ici vous devriez enregistrer la commande dans votre base de données
      // Pour l'exemple, nous affichons juste un message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.commandeToEdit == null 
              ? "Commande enregistrée avec succès" 
              : "Commande modifiée avec succès"),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      // Si c'est une modification, retourner à l'écran précédent
      if (widget.commandeToEdit != null) {
        Navigator.pop(context, commande);
      }
    } else if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un article"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _genererPDF() async {
    if (_formKey.currentState!.validate() && _articles.isNotEmpty) {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(' BON D`ACHAT ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Référence: ${_referenceController.text}'),
                        pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                        pw.Text('Responsable: ${_responsableController.text}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Fournisseur: ${_selectedFournisseur ?? ""}'),
                        pw.Text('Adresse : ${_adresseLivraisonController.text}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Liste des articles:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Article')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Qté')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Prix HT')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('TVA')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Total HT')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Total TTC')),
                      ],
                    ),
                    for (var article in _articles)
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(article['nom'])),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(article['quantite'].toString())),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${article['prixHT'].toStringAsFixed(2)} €')),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${article['tva']}%')),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${article['montantHT'].toStringAsFixed(2)} €')),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${article['montantTTC'].toStringAsFixed(2)} €')),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Sous-total HT: ${_sousTotal.toStringAsFixed(2)} €'),
                        pw.Text('TVA: ${_totalTVA.toStringAsFixed(2)} €'),
                        if (double.parse(_remiseController.text) > 0)
                          pw.Text('Remise: -${double.parse(_remiseController.text).toStringAsFixed(2)} €'),
                        pw.Divider(),
                        pw.Text('Total HT: ${_totalHT.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Total TTC: ${_totalCommande.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/commande_${_referenceController.text}_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf");
      await file.writeAsBytes(await pdf.save());

      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF généré avec succès"),
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

  void _ajouterFournisseur(Fournisseur fournisseur) {
    setState(() {
      _fournisseurs.add(fournisseur.nomFournisseur);
      _selectedFournisseur = fournisseur.nom;
    });
  }

  Future<void> _navigateToAddFournisseurScreen(BuildContext context) async {
    final Fournisseur? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurScreen(fournisseurData: {},),
      ),
    );

    if (result != null) {
      _ajouterFournisseur(result);
    }
  }

  Future<void> _navigateToAddArticleScreen(BuildContext context) async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
MaterialPageRoute(
  builder: (context) => ArticleFormScreen(
    onSave: (article) async {
      // Handle saving the article here
      print('Saving article: $article');
      // You can return something if needed
      return;
    },
  ),
        )    );

    if (result != null) {
      _ajouterArticle(result);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commandeToEdit == null ? 'Bon d\'achat' : 'Modifier commande'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Informations Générales', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      isSmallScreen
                          ? Column(
                              children: [
                                TextFormField(
                                  controller: _referenceController,
                                  decoration: InputDecoration(
                                    labelText: 'Numéro de référence',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.numbers),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                  ),
                                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_today),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _referenceController,
                                    decoration: InputDecoration(
                                      labelText: 'Numéro de référence',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.numbers),
                                    ),
                                    validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Date',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      child: Text(
                                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: !isSmallScreen ? 16.0 : 8.0),
                      TextFormField(
                        controller: _responsableController,
                        decoration: InputDecoration(
                          labelText: 'Responsable de achat ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          contentPadding: isSmallScreen ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0) : null,
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      TextFormField(
                        controller: _adresseLivraisonController,
                        decoration: InputDecoration(
                          labelText: 'Adresse ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          contentPadding: isSmallScreen ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0) : null,
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Fournisseur', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                     DropdownButtonFormField<String>(
  value: _selectedFournisseur,
  onChanged: (String? newValue) {
    setState(() {
      _selectedFournisseur = newValue;
    });
  },
  items: _fournisseurs.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }).toList(),
  decoration: InputDecoration(
    labelText: 'Sélectionner un fournisseur',
    border: const OutlineInputBorder(),
    prefixIcon: const Icon(Icons.business),
    contentPadding: isSmallScreen 
        ? const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)
        : null,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner un fournisseur';
    }
    return null;
  },
  isExpanded: true,
  hint: const Text('Choisissez un fournisseur'),
  icon: const Icon(Icons.arrow_drop_down),
  style: TextStyle(
    fontSize: isSmallScreen ? 14 : 16,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  ),
),
SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      TextButton.icon(
                        onPressed: () => _navigateToAddFournisseurScreen(context),
                        icon: Icon(Icons.add_business, size: isSmallScreen ? 16 : 24),
                        label: Text(
                          'Ajouter un nouveau fournisseur',
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                          padding: isSmallScreen ? EdgeInsets.symmetric(vertical: 4, horizontal: 8) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionHeader('Articles', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
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
                        items: _listeArticles
                            .map(
                              (article) => DropdownMenuItem<String>(
                                value: article['nom'],
                                child: Text(article['nom'], style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un article',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory),
                          contentPadding: isSmallScreen ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0) : null,
                        ),
                        isExpanded: true,
                      ),
                      SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                      TextButton.icon(
                        onPressed: () => _navigateToAddArticleScreen(context),
                        icon: Icon(Icons.add_shopping_cart, size: isSmallScreen ? 16 : 24),
                        label: Text(
                          'Ajouter un nouvel article',
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                          padding: isSmallScreen ? EdgeInsets.symmetric(vertical: 4, horizontal: 8) : null,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      
                      isSmallScreen
                          ? Column(
                              children: [
                                TextFormField(
                                  controller: _quantiteController,
                                  decoration: InputDecoration(
                                    labelText: 'Quantité',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.format_list_numbered),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Quantité invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _prixController,
                                  decoration: InputDecoration(
                                    labelText: 'Prix HT',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                      return 'Prix invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _tvaController,
                                  decoration: InputDecoration(
                                    labelText: 'TVA (%)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.percent),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Champ requis';
                                    }
                                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                                      return 'TVA invalide';
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
                                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
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
                                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
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
                                      if (double.tryParse(value) == null || double.parse(value) < 0) {
                                        return 'TVA invalide';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _selectedArticle != null) {
                            _ajouterArticle({
                              'nom': _selectedArticle!,
                              'quantite': int.parse(_quantiteController.text),
                              'prixHT': double.parse(_prixController.text),
                              'tva': double.parse(_tvaController.text),
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: isSmallScreen ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) : null,
                        ),
                        child: Text(
                          'Ajouter l\'article',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_articles.isNotEmpty) ...[
                _buildSectionHeader('Liste des Articles', isSmallScreen),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                    child: Column(
                      children: [
                        for (var i = 0; i < _articles.length; i++)
                          ListTile(
                            title: Text(
                              _articles[i]['nom'],
                              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            ),
                            subtitle: Text(
                              'Quantité: ${_articles[i]['quantite']} - Prix HT: ${currencyFormat.format(_articles[i]['prixHT'])} - TVA: ${_articles[i]['tva']}%',
                              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, size: isSmallScreen ? 20 : 24),
                              onPressed: () => _supprimerArticle(i),
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              _buildSectionHeader('Totaux', isSmallScreen),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 8.0 : 16.0),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _remiseController,
                        decoration: InputDecoration(
                          labelText: 'Remise (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.discount),
                          contentPadding: isSmallScreen ? EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0) : null,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _calculerTotal(),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Champ requis';
                          }
                          if (double.tryParse(value) == null || double.parse(value) < 0) {
                            return 'Remise invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 8.0 : 16.0),
                      Text(
                        'Sous-total HT: ${currencyFormat.format(_sousTotal)}',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      Text(
                        'TVA: ${currencyFormat.format(_totalTVA)}',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                      if (double.parse(_remiseController.text) > 0)
                        Text(
                          'Remise: -${currencyFormat.format(double.parse(_remiseController.text))}',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16, color: Colors.red),
                        ),
                      Divider(),
                      Text(
                        'Total HT: ${currencyFormat.format(_totalHT)}',
                        style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total TTC: ${currencyFormat.format(_totalCommande)}',
                        style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _enregistrerCommande,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: isSmallScreen ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) : null,
                    ),
                    child: Text(
                      widget.commandeToEdit == null ? 'Enregistrer' : 'Modifier',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _genererPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: isSmallScreen ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) : null,
                    ),
                    child: Text(
                      'Générer PDF',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoriqueAchatsDirectsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      padding: isSmallScreen 
                          ? EdgeInsets.symmetric(vertical: 8, horizontal: 12) 
                          : EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      side: BorderSide(color: Colors.teal),
                      elevation: 2,
                    ),
                    child: Text(
                      'Historique',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(top: isSmallScreen ? 8.0 : 16.0, bottom: isSmallScreen ? 4.0 : 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 18 : 22,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}