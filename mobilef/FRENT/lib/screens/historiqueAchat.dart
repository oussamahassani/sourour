import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HistoriqueAchatsDirectsScreen extends StatefulWidget {
  @override
  _HistoriqueAchatsDirectsScreenState createState() => _HistoriqueAchatsDirectsScreenState();
}

class _HistoriqueAchatsDirectsScreenState extends State<HistoriqueAchatsDirectsScreen> {
  List<Map<String, dynamic>> _commandes = [
    {
      'reference': 'CMD-2023-001',
      'fournisseur': 'Fournisseur A',
      'date': DateTime(2023, 1, 15),
      'total': 1250.50,
      'statut': 'Terminé',
      'adresse': '123 Rue du Commerce, Paris',
      'email': 'contact@fournisseura.com',
      'telephone': '0123456789',
      'notes': 'Livraison prévue le 20/01/2023',
      'articles': [
        {'nom': 'Produit X', 'quantite': 2, 'prixHT': 250.00, 'tva': 20.0},
        {'nom': 'Produit Y', 'quantite': 1, 'prixHT': 750.50, 'tva': 20.0},
      ],
    },
    {
      'reference': 'CMD-2023-002',
      'fournisseur': 'Fournisseur B',
      'date': DateTime(2023, 2, 10),
      'total': 845.75,
      'statut': 'En cours',
      'adresse': '456 Avenue des Affaires, Lyon',
      'email': 'contact@fournisseurb.com',
      'telephone': '0987654321',
      'notes': '',
      'articles': [
        {'nom': 'Produit Z', 'quantite': 5, 'prixHT': 150.00, 'tva': 10.0},
        {'nom': 'Produit W', 'quantite': 3, 'prixHT': 65.25, 'tva': 10.0},
      ],
    },
  ];

  List<Map<String, dynamic>> _commandesFiltrees = [];
  final TextEditingController _rechercheController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _commandesFiltrees = List.from(_commandes);
  }

  void _filtrerCommandes(String query) {
    setState(() {
      _commandesFiltrees = _commandes.where((commande) {
        final reference = commande['reference'].toString().toLowerCase();
        final fournisseur = commande['fournisseur'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
       
        return reference.contains(searchLower) ||
               fournisseur.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _genererPDF(Map<String, dynamic> commande) async {
    try {
      final pdf = pw.Document();

      // Définir les styles
      final headerStyle = pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      );

      final normalStyle = pw.TextStyle(
        fontSize: 10,
      );

      final boldStyle = pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('BON D\'ACHAT - ${commande['reference']}',
                      style: headerStyle),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(commande['date'])}',
                            style: boldStyle),
                        if (commande['notes'] != null && commande['notes'].isNotEmpty)
                          pw.Text('Notes: ${commande['notes']}', style: normalStyle),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Fournisseur: ${commande['fournisseur']}',
                            style: boldStyle),
                        pw.Text('Tél: ${commande['telephone']}', style: normalStyle),
                        pw.Text('Email: ${commande['email']}', style: normalStyle),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Liste des articles:', style: headerStyle),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  context: context,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blue800),
                  headers: ['Article', 'Qté', 'Prix HT', 'TVA', 'Total HT'],
                  data: commande['articles'].map<List<String>>((article) {
                    return [
                      article['nom'],
                      article['quantite'].toString(),
                      '${article['prixHT'].toStringAsFixed(2)} €',
                      '${article['tva']}%',
                      '${(article['prixHT'] * article['quantite']).toStringAsFixed(2)} €',
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Total: ${currencyFormat.format(commande['total'])}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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
                        pw.Text('Signature fournisseur', style: boldStyle),
                        pw.SizedBox(height: 50),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('Signature client', style: boldStyle),
                        pw.SizedBox(height: 50),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Sauvegarder le PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/commande_${commande['reference']}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Ouvrir le PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'ouvrir le PDF: ${result.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la génération du PDF: $e")),
      );
    }
  }

  void _supprimerCommande(int index) {
    setState(() {
      _commandes.removeAt(index);
      _filtrerCommandes(_rechercheController.text);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Commande supprimée avec succès")),
    );
  }

  void _modifierCommande(int index) {
    final commande = _commandes[index];
    final referenceController = TextEditingController(text: commande['reference']);
    final fournisseurController = TextEditingController(text: commande['fournisseur']);
    final dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(commande['date']));
    final statutController = TextEditingController(text: commande['statut']);
    final adresseController = TextEditingController(text: commande['adresse']);
    final emailController = TextEditingController(text: commande['email']);
    final telephoneController = TextEditingController(text: commande['telephone']);
    final notesController = TextEditingController(text: commande['notes']);
   
    List<Map<String, dynamic>> articles = List.from(commande['articles']);
    List<TextEditingController> articleNomControllers = [];
    List<TextEditingController> articleQteControllers = [];
    List<TextEditingController> articlePrixControllers = [];
    List<TextEditingController> articleTvaControllers = [];
   
    for (var article in articles) {
      articleNomControllers.add(TextEditingController(text: article['nom']));
      articleQteControllers.add(TextEditingController(text: article['quantite'].toString()));
      articlePrixControllers.add(TextEditingController(text: article['prixHT'].toString()));
      articleTvaControllers.add(TextEditingController(text: article['tva'].toString()));
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Modifier la commande"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(labelText: 'Référence'),
                  ),
                  TextField(
                    controller: fournisseurController,
                    decoration: InputDecoration(labelText: 'Fournisseur'),
                  ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date (dd/MM/yyyy)'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: commande['date'],
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        dateController.text = DateFormat('dd/MM/yyyy').format(date);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: statutController.text,
                    items: ['Terminé', 'En cours', 'Annulé']
                        .map((statut) => DropdownMenuItem(
                              value: statut,
                              child: Text(statut),
                            ))
                        .toList(),
                    onChanged: (value) {
                      statutController.text = value!;
                    },
                    decoration: InputDecoration(labelText: 'Statut'),
                  ),
                  TextField(
                    controller: adresseController,
                    decoration: InputDecoration(labelText: 'Adresse'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: telephoneController,
                    decoration: InputDecoration(labelText: 'Téléphone'),
                    keyboardType: TextInputType.phone,
                  ),
                 
                  SizedBox(height: 16),
                  Text("Articles:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                 
                  for (int i = 0; i < articles.length; i++)
                    Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            TextField(
                              controller: articleNomControllers[i],
                              decoration: InputDecoration(labelText: 'Nom article'),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: articleQteControllers[i],
                                    decoration: InputDecoration(labelText: 'Quantité'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: articlePrixControllers[i],
                                    decoration: InputDecoration(labelText: 'Prix HT'),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  ),
                                ),
                              ],
                            ),
                            TextField(
                              controller: articleTvaControllers[i],
                              decoration: InputDecoration(labelText: 'TVA (%)'),
                              keyboardType: TextInputType.number,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  articles.removeAt(i);
                                  articleNomControllers.removeAt(i);
                                  articleQteControllers.removeAt(i);
                                  articlePrixControllers.removeAt(i);
                                  articleTvaControllers.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                 
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        articles.add({
                          'nom': 'Nouvel article',
                          'quantite': 1,
                          'prixHT': 0.0,
                          'tva': 20.0,
                        });
                        articleNomControllers.add(TextEditingController(text: 'Nouvel article'));
                        articleQteControllers.add(TextEditingController(text: '1'));
                        articlePrixControllers.add(TextEditingController(text: '0.0'));
                        articleTvaControllers.add(TextEditingController(text: '20.0'));
                      });
                    },
                    child: Text("Ajouter un article"),
                  ),
                 
                  SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  List<Map<String, dynamic>> updatedArticles = [];
                  for (int i = 0; i < articles.length; i++) {
                    updatedArticles.add({
                      'nom': articleNomControllers[i].text,
                      'quantite': int.tryParse(articleQteControllers[i].text) ?? 0,
                      'prixHT': double.tryParse(articlePrixControllers[i].text) ?? 0.0,
                      'tva': double.tryParse(articleTvaControllers[i].text) ?? 20.0,
                    });
                  }
                 
                  double newTotal = updatedArticles.fold(0.0, (sum, article) {
                    return sum + (article['prixHT'] * article['quantite'] * (1 + article['tva'] / 100));
                  });
                 
                  setState(() {
                    _commandes[index] = {
                      'reference': referenceController.text,
                      'fournisseur': fournisseurController.text,
                      'date': DateFormat('dd/MM/yyyy').parse(dateController.text),
                      'total': newTotal,
                      'articles': updatedArticles,
                      'statut': statutController.text,
                      'adresse': adresseController.text,
                      'email': emailController.text,
                      'telephone': telephoneController.text,
                      'notes': notesController.text,
                    };
                    _filtrerCommandes(_rechercheController.text);
                  });
                 
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Commande modifiée avec succès")),
                  );
                },
                child: Text("Enregistrer"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _afficherDetails(int index) {
    final commande = _commandesFiltrees[index];
   
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Détails de la commande ${commande['reference']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("Référence:", commande['reference']),
              _buildDetailRow("Fournisseur:", commande['fournisseur']),
              _buildDetailRow("Date:", DateFormat('dd/MM/yyyy').format(commande['date'])),
              _buildDetailRow("Statut:", commande['statut']),
              _buildDetailRow("Adresse:", commande['adresse']),
              _buildDetailRow("Email:", commande['email']),
              _buildDetailRow("Téléphone:", commande['telephone']),
             
              SizedBox(height: 16),
              Text("Articles:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              for (var article in commande['articles'])
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("- ${article['nom']}", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Quantité: ${article['quantite']}"),
                            Text("Prix HT: ${currencyFormat.format(article['prixHT'])}"),
                            Text("TVA: ${article['tva']}%"),
                            Text("Total HT: ${currencyFormat.format(article['prixHT'] * article['quantite'])}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
             
              SizedBox(height: 16),
              _buildDetailRow("Total:", currencyFormat.format(commande['total']), isBold: true),
             
              if (commande['notes'] != null && commande['notes'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(commande['notes']),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique des Achats Directs"),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(_commandes),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _rechercheController,
              decoration: InputDecoration(
                labelText: 'Rechercher par référence ou fournisseur',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filtrerCommandes,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _commandesFiltrees.length,
              itemBuilder: (context, index) {
                final commande = _commandesFiltrees[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(commande['reference']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fournisseur: ${commande['fournisseur']}"),
                        Text("Date: ${DateFormat('dd/MM/yyyy').format(commande['date'])}"),
                        Text("Total: ${currencyFormat.format(commande['total'])}"),
                        Row(
                          children: [
                            Chip(
                              label: Text(commande['statut']),
                              backgroundColor: _getStatusColor(commande['statut']),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Détails"),
                          value: 'details',
                        ),
                        PopupMenuItem(
                          child: Text("Modifier"),
                          value: 'modifier',
                        ),
                        PopupMenuItem(
                          child: Text("Générer PDF"),
                          value: 'pdf',
                        ),
                        PopupMenuItem(
                          child: Text("Supprimer", style: TextStyle(color: Colors.red)),
                          value: 'supprimer',
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'details':
                            _afficherDetails(index);
                            break;
                          case 'modifier':
                            _modifierCommande(index);
                            break;
                          case 'pdf':
                            _genererPDF(commande);
                            break;
                          case 'supprimer':
                            _supprimerCommande(index);
                            break;
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'Terminé':
        return Colors.green.shade100;
      case 'En cours':
        return Colors.blue.shade100;
      case 'Annulé':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> commandes;

  CustomSearchDelegate(this.commandes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = commandes.where((commande) {
      final reference = commande['reference'].toString().toLowerCase();
      final fournisseur = commande['fournisseur'].toString().toLowerCase();
      final searchLower = query.toLowerCase();
     
      return reference.contains(searchLower) ||
             fournisseur.contains(searchLower);
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = commandes.where((commande) {
      final reference = commande['reference'].toString().toLowerCase();
      final fournisseur = commande['fournisseur'].toString().toLowerCase();
      final searchLower = query.toLowerCase();
     
      return reference.contains(searchLower) ||
             fournisseur.contains(searchLower);
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final commande = results[index];
        return ListTile(
          title: Text(commande['reference']),
          subtitle: Text("Fournisseur: ${commande['fournisseur']} - Total: ${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(commande['total'])}"),
          onTap: () {
            close(context, commande);
          },
        );
      },
    );
  }
}