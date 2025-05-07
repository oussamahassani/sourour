import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';

class FormulaireVenteScreen extends StatefulWidget {
  @override
  _FormulaireVenteScreenState createState() => _FormulaireVenteScreenState();
}

class _FormulaireVenteScreenState extends State<FormulaireVenteScreen> {
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _montantRecuController = TextEditingController();
  final TextEditingController _modePaiementController = TextEditingController();
  final TextEditingController _statutPaiementController = TextEditingController(text: 'Payé');
  final TextEditingController _totalVenteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedClient;
  List<Map<String, dynamic>> _paiements = [];
  double _totalVente = 0.0;
  double _totalRecu = 0.0;
  double _resteARecvoir = 0.0;

  // Liste de clients existants (simulée)
  List<String> _clients = ['Client 1', 'Client 2'];

  // Formatter pour les montants
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

  // Fonction pour ajouter un paiement à la liste
  void _ajouterPaiement() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        double montantRecu = double.tryParse(_montantRecuController.text) ?? 0.0;

        _paiements.add({
          'date': _selectedDate,
          'montantRecu': montantRecu,
          'modePaiement': _modePaiementController.text,
          'statut': _statutPaiementController.text,
        });

        _calculerTotaux();

        // Réinitialiser les champs
        _montantRecuController.clear();
        _modePaiementController.clear();
        _statutPaiementController.text = 'Payé';
      });
    }
  }

  // Calcul des totaux
  void _calculerTotaux() {
    double totalRecu = _paiements.fold(
      0.0,
      (sum, paiement) => sum + paiement['montantRecu'],
    );

    setState(() {
      _totalRecu = totalRecu;
      _resteARecvoir = _totalVente - totalRecu;
    });
  }

  // Supprimer un paiement de la liste
  void _supprimerPaiement(int index) {
    setState(() {
      _paiements.removeAt(index);
      _calculerTotaux();
    });
  }

  // Sélection de la date de paiement
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

  // Enregistrer la vente
  void _enregistrerVente() {
    if (_formKey.currentState!.validate() && _paiements.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Paiement de vente enregistré avec succès"),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      // Logique pour sauvegarder dans une base de données
    } else if (_paiements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un paiement"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Générer un PDF
  Future<void> _genererPDF() async {
    if (_formKey.currentState!.validate() && _paiements.isNotEmpty) {
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
                  child: pw.Text('FORMULAIRE DE VENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Référence: ${_referenceController.text}'),
                        pw.Text('Date de paiement: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                        pw.Text('Responsable: ${_responsableController.text}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Client: ${_selectedClient ?? ""}'),
                        pw.Text('Total vente: ${currencyFormat.format(_totalVente)}'),
                        pw.Text('Total reçu: ${currencyFormat.format(_totalRecu)}'),
                        pw.Text('Reste à recevoir: ${currencyFormat.format(_resteARecvoir)}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Liste des paiements:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Date')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Montant reçu')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Mode de paiement')),
                        pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('Statut')),
                      ],
                    ),
                    for (var paiement in _paiements)
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(DateFormat('dd/MM/yyyy').format(paiement['date']))),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text('${currencyFormat.format(paiement['montantRecu'])}')),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(paiement['modePaiement'])),
                          pw.Padding(padding: pw.EdgeInsets.all(5), child: pw.Text(paiement['statut'])),
                        ],
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Enregistrer le PDF
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/vente_${_referenceController.text}_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Ouvrir le PDF
      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF généré avec succès"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else if (_paiements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un paiement"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulaire de Vente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations Générales
              _buildSectionHeader('Informations Générales'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
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
                                  labelText: 'Date de paiement',
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _responsableController,
                        decoration: InputDecoration(
                          labelText: 'Responsable de vente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalVenteController,
                        decoration: InputDecoration(
                          labelText: 'Total de la vente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Champ requis';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _totalVente = double.tryParse(value) ?? 0.0;
                            _calculerTotaux();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Section Client
              _buildSectionHeader('Client'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedClient,
                        onChanged: (value) => setState(() => _selectedClient = value),
                        items: _clients
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sélectionner un client',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => value == null ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Logique pour ajouter un nouveau client
                          setState(() {
                            _clients.add('Nouveau Client ${_clients.length + 1}');
                            _selectedClient = _clients.last;
                          });
                        },
                        icon: Icon(Icons.add_circle),
                        label: const Text('Ajouter un nouveau client'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Paiement
              _buildSectionHeader('Paiement'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _montantRecuController,
                              decoration: InputDecoration(
                                labelText: 'Montant reçu',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Champ requis';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Montant invalide';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modePaiementController,
                              decoration: InputDecoration(
                                labelText: 'Mode de paiement',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.payment),
                              ),
                              validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _statutPaiementController.text,
                        onChanged: (value) => setState(() => _statutPaiementController.text = value!),
                        items: ['Payé', 'Partiellement payé', 'En attente']
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        decoration: InputDecoration(
                          labelText: 'Statut du paiement',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.assignment_turned_in),
                        ),
                        validator: (value) => value == null ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _ajouterPaiement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Ajouter le paiement'),
                      ),
                    ],
                  ),
                ),
              ),

              // Section Liste des paiements
              if (_paiements.isNotEmpty) ...[
                _buildSectionHeader('Liste des paiements'),
                Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        for (var i = 0; i < _paiements.length; i++)
                          ListTile(
                            title: Text('Montant reçu: ${currencyFormat.format(_paiements[i]['montantRecu'])}'),
                            subtitle: Text(
                                'Date: ${DateFormat('dd/MM/yyyy').format(_paiements[i]['date'])} - Mode: ${_paiements[i]['modePaiement']} - Statut: ${_paiements[i]['statut']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _supprimerPaiement(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // Section Totaux
              _buildSectionHeader('Totaux'),
              Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total vente:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(_totalVente)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total reçu:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(_totalRecu)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reste à recevoir:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(currencyFormat.format(_resteARecvoir)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Boutons de validation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _enregistrerVente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                  ElevatedButton(
                    onPressed: _genererPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Générer PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoriqueVentesScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Historique'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour créer un en-tête de section
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}

class HistoriqueVentesScreen extends StatefulWidget {
  @override
  _HistoriqueVentesScreenState createState() => _HistoriqueVentesScreenState();
}

class _HistoriqueVentesScreenState extends State<HistoriqueVentesScreen> {
  // Liste simulée pour l'historique des ventes
  List<Map<String, dynamic>> _historiqueVentes = [
    {
      'id': '1',
      'reference': 'VENTE-2023-001',
      'client': 'Client A',
      'date': DateTime(2023, 5, 15),
      'totalVente': 1500.0,
      'totalRecu': 1500.0,
      'statut': 'Payé',
    },
    {
      'id': '2',
      'reference': 'VENTE-2023-002',
      'client': 'Client B',
      'date': DateTime(2023, 5, 10),
      'totalVente': 2500.0,
      'totalRecu': 1500.0,
      'statut': 'Partiellement payé',
    },
  ];

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Ventes'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Ajouter la fonctionnalité de recherche
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _historiqueVentes.length,
        itemBuilder: (context, index) {
          final vente = _historiqueVentes[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text('Réf: ${vente['reference']} - ${vente['client']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${DateFormat('dd/MM/yyyy').format(vente['date'])}'),
                  Text('Total: ${currencyFormat.format(vente['totalVente'])}'),
                  Text('Statut: ${vente['statut']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                    onPressed: () => _voirDetails(vente),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: () => _modifierVente(vente),
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: Colors.orange),
                    onPressed: () => _genererPDF(vente),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _supprimerVente(vente['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _voirDetails(Map<String, dynamic> vente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la vente'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Référence: ${vente['reference']}'),
              Text('Client: ${vente['client']}'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(vente['date'])}'),
              Text('Total vente: ${currencyFormat.format(vente['totalVente'])}'),
              Text('Total reçu: ${currencyFormat.format(vente['totalRecu'])}'),
              Text('Statut: ${vente['statut']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _modifierVente(Map<String, dynamic> vente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaireVenteScreen(),
      ),
    );
  }

  void _genererPDF(Map<String, dynamic> vente) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('DÉTAIL DE LA VENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Référence: ${vente['reference']}'),
              pw.Text('Client: ${vente['client']}'),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(vente['date'])}'),
              pw.Text('Total vente: ${currencyFormat.format(vente['totalVente'])}'),
              pw.Text('Total reçu: ${currencyFormat.format(vente['totalRecu'])}'),
              pw.Text('Statut: ${vente['statut']}'),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/detail_vente_${vente['reference']}.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  void _supprimerVente(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer cette vente ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _historiqueVentes.removeWhere((v) => v['id'] == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vente supprimée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}