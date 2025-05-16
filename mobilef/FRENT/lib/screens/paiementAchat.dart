// lib/screens/formulaire_paiement_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fournisseur.dart';
import '../models/paiement.dart';
import '../providers/fournisseur_provider.dart';
import '../providers/paiement_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'fournisseur/fournisseur.dart';
import '../services/achat_service.dart';
import '../services/paiement_service.dart';

class FormulairePaiementScreen extends StatefulWidget {
  @override
  _FormulairePaiementScreenState createState() =>
      _FormulairePaiementScreenState();
}

class _FormulairePaiementScreenState extends State<FormulairePaiementScreen> {
  final TextEditingController _responsableController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _montantPayeController = TextEditingController();
  final TextEditingController _modePaiementController = TextEditingController();
  final TextEditingController _statutPaiementController = TextEditingController(
    text: 'Payé',
  );
  final TextEditingController _totalAPayerController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedFournisseurId;
  List<Map<String, dynamic>> _paiements = [];
  double _totalAPayer = 0.0;
  double _totalPaye = 0.0;
  double _resteAPayer = 0.0;
  List<Map<String, String>> _clients = [];
  List<Paiement> _payment = [];
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    // Fetch fournisseurs when the screen loads
    //Provider.of<FournisseurProvider>(context, listen: false).loadFournisseurs();
  }

  Future<void> _loadData() async {
    final fournisseurService = PurchaseService();
    _clients = await fournisseurService.getfetchSuppliers();
    final peiementService = PaiementService();
    _payment = await peiementService.fetchAchatPaiements();
  }

  void _ajouterPaiement() {
    setState(() {
      double montantPaye = double.tryParse(_montantPayeController.text) ?? 0.0;

      _paiements.add({
        'date': _selectedDate,
        'montantPaye': montantPaye,
        'modePaiement': _modePaiementController.text,
        'statut': _statutPaiementController.text,
      });

      _calculerTotaux();

      _montantPayeController.clear();
      _modePaiementController.clear();
      _statutPaiementController.text = 'Payé';
    });
  }

  void _calculerTotaux() {
    double totalPaye = _paiements.fold(
      0.0,
      (sum, paiement) => sum + paiement['montantPaye'],
    );

    setState(() {
      _totalPaye = totalPaye;
      _resteAPayer = _totalAPayer - totalPaye;
    });
  }

  void _supprimerPaiement(int index) {
    setState(() {
      _paiements.removeAt(index);
      _calculerTotaux();
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

  void _enregistrerPaiement() async {
    if (_formKey.currentState!.validate() &&
        _paiements.isNotEmpty &&
        _selectedFournisseurId != null) {
      final venteData = {
        'reference': _referenceController.text,
        'date': _selectedDate.toIso8601String(),
        'responsable': _responsableController.text,
        'totalVente': _totalAPayer,
        'fournisseurId': _selectedFournisseurId,
        "resteAPayer": _resteAPayer,
        'paiements':
            _paiements
                .map(
                  (p) => {
                    'montantRecu': p['montantPaye'],
                    'modePaiement': p['modePaiement'],
                    'statut': p['statut'],
                    'date': p['date'].toIso8601String(),
                  },
                )
                .toList(),
      };
      Paiement paiement = Paiement.fromMap(venteData);
      final paiementService = PaiementService();

      await paiementService.createPaiement(paiement);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Paiement enregistré avec succès"),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      setState(() {
        _paiements.clear();
        _totalPaye = 0.0;
        _resteAPayer = _totalAPayer;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs et ajouter au moins un paiement",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _genererPDF() async {
    if (_formKey.currentState!.validate() && _paiements.isNotEmpty) {
      final pdf = pw.Document();

      final fournisseurProvider = Provider.of<FournisseurProvider>(
        context,
        listen: false,
      );
      final selectedFournisseur = fournisseurProvider.fournisseurs.firstWhere(
        (f) => f.id == _selectedFournisseurId,
        orElse:
            () => Fournisseur(
              type: '',
              adresse: '',
              email: '',
              telephone: '',
              dateCreation: DateTime.now(),
            ),
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'FORMULAIRE DE PAIEMENT',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Référence: ${_referenceController.text}'),
                        pw.Text(
                          'Date de paiement: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                        ),
                        pw.Text('Responsable: ${_responsableController.text}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fournisseur: ${selectedFournisseur.nomFournisseur}',
                        ),
                        pw.Text(
                          'Total à payer: ${currencyFormat.format(_totalAPayer)}',
                        ),
                        pw.Text(
                          'Total payé: ${currencyFormat.format(_totalPaye)}',
                        ),
                        pw.Text(
                          'Reste à payer: ${currencyFormat.format(_resteAPayer)}',
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Liste des paiements:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Date'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Montant payé'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Mode de paiement'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text('Statut'),
                        ),
                      ],
                    ),
                    for (var paiement in _paiements)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                              DateFormat('dd/MM/yyyy').format(paiement['date']),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(
                              '${currencyFormat.format(paiement['montantPaye'])}',
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(paiement['modePaiement']),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text(paiement['statut']),
                          ),
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
      final file = File(
        "${output.path}/paiement_${_referenceController.text}_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf",
      );
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF généré avec succès"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un paiement"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToAddFournisseurScreen(BuildContext context) async {
    final Fournisseur? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FournisseurScreen(fournisseurData: {}),
      ),
    );

    if (result != null) {
      Provider.of<FournisseurProvider>(
        context,
        listen: false,
      ).addFournisseur(result);
      setState(() {
        _selectedFournisseurId = result.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurProvider = Provider.of<FournisseurProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulaire de Paiement'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body:
          fournisseurProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations Générales
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
                                      validator:
                                          (value) =>
                                              value!.isEmpty
                                                  ? 'Champ requis'
                                                  : null,
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
                                          prefixIcon: Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        child: Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_selectedDate),
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
                                  labelText: 'Responsable de paiement',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _totalAPayerController,
                                decoration: InputDecoration(
                                  labelText: 'Total à payer',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Montant invalide';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _totalAPayer =
                                        double.tryParse(value) ?? 0.0;
                                    _calculerTotaux();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fournisseur
                      _buildSectionHeader('Fournisseur'),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedFournisseurId,
                                onChanged:
                                    (value) => setState(
                                      () => _selectedFournisseurId = value,
                                    ),
                                items:
                                    _clients
                                        .map(
                                          (f) => DropdownMenuItem(
                                            value: f["id"],
                                            child: Text(f["name"] ?? 'Inconnu'),
                                          ),
                                        )
                                        .toList(),
                                decoration: InputDecoration(
                                  labelText: 'Sélectionner un fournisseur',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business),
                                ),
                                validator:
                                    (value) =>
                                        value == null ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed:
                                    () => _navigateToAddFournisseurScreen(
                                      context,
                                    ),
                                icon: Icon(Icons.add_business),
                                label: const Text(
                                  'Ajouter un nouveau fournisseur',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Paiement
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
                                      controller: _montantPayeController,
                                      decoration: InputDecoration(
                                        labelText: 'Montant payé',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.attach_money),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Champ requis';
                                        }
                                        if (double.tryParse(value) == null ||
                                            double.parse(value) <= 0) {
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
                                      validator:
                                          (value) =>
                                              value!.isEmpty
                                                  ? 'Champ requis'
                                                  : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _statutPaiementController.text,
                                onChanged:
                                    (value) => setState(
                                      () =>
                                          _statutPaiementController.text =
                                              value!,
                                    ),
                                items:
                                    ['Payé', 'Partiellement payé', 'En attente']
                                        .map(
                                          (status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ),
                                        )
                                        .toList(),
                                decoration: InputDecoration(
                                  labelText: 'Statut du paiement',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.assignment_turned_in),
                                ),
                                validator:
                                    (value) =>
                                        value == null ? 'Champ requis' : null,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _ajouterPaiement,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Ajouter le paiement'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Liste des paiements
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
                                    title: Text(
                                      'Montant payé: ${currencyFormat.format(_paiements[i]['montantPaye'])}',
                                    ),
                                    subtitle: Text(
                                      'Date: ${DateFormat('dd/MM/yyyy').format(_paiements[i]['date'])} - Mode: ${_paiements[i]['modePaiement']} - Statut: ${_paiements[i]['statut']}',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _supprimerPaiement(i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Totaux
                      _buildSectionHeader('Totaux'),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total à payer:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(currencyFormat.format(_totalAPayer)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total payé:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(currencyFormat.format(_totalPaye)),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reste à payer:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(currencyFormat.format(_resteAPayer)),
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
                            onPressed: _enregistrerPaiement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Enregistrer'),
                          ),
                          ElevatedButton(
                            onPressed: _genererPDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Générer PDF'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => HistoriquePaiementsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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

class HistoriquePaiementsScreen extends StatefulWidget {
  @override
  _HistoriquePaiementsScreenState createState() =>
      _HistoriquePaiementsScreenState();
}

class _HistoriquePaiementsScreenState extends State<HistoriquePaiementsScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );
  List<Paiement> _payment = [];
  bool _isLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _loadData() async {
    final peiementService = PaiementService();
    _payment = await peiementService.fetchAchatPaiements();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _voirDetails(Paiement paiement) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Détails du paiement'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Référence: ${paiement.reference}'),
                  Text('Fournisseur ID: ${paiement.fournisseurId}'),
                  Text('Date: ${paiement.createdAt}'),
                  Text(
                    'Total à payer: ${currencyFormat.format(paiement.totalAPayer)}',
                  ),
                  Text(
                    'Total payé: ${currencyFormat.format(paiement.totalPaye)}',
                  ),
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

  void _modifierPaiement(Paiement paiement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                FormulairePaiementScreen(), // TODO: Pass paiement data for editing
      ),
    );
  }

  Future<void> _genererPDF(Paiement paiement) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'DÉTAIL DU PAIEMENT',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Référence: ${paiement.reference}'),
              pw.Text('Fournisseur ID: ${paiement.fournisseurId}'),
              pw.Text('Date: ${paiement.createdAt}'),
              pw.Text(
                'Total à payer: ${currencyFormat.format(paiement.totalAPayer)}',
              ),
              pw.Text(
                'Total payé: ${currencyFormat.format(paiement.totalPaye)}',
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      "${output.path}/detail_paiement_${paiement.reference}.pdf",
    );
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  void _supprimerPaiement(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Voulez-vous vraiment supprimer ce paiement ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await Provider.of<PaiementProvider>(
                    context,
                    listen: false,
                  ).deletePaiement(id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Paiement supprimé avec succès'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Paiements'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Add search functionality
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _payment.isEmpty
              ? Center(child: Text('Aucun paiement trouvé'))
              : ListView.builder(
                itemCount: _payment.length,
                itemBuilder: (context, index) {
                  final paiement = _payment[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        'Réf: ${paiement.reference} - Fournisseur: ${paiement.fournisseurId}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${paiement.createdAt}'),
                          Text(
                            'Total: ${currencyFormat.format(paiement.totalAPayer)}',
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Colors.blue,
                            ),
                            onPressed: () => _voirDetails(paiement),
                          ),
                          /*   IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _modifierPaiement(paiement),
                          ),
                          */
                          IconButton(
                            icon: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.orange,
                            ),
                            onPressed: () => _genererPDF(paiement),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _supprimerPaiement(paiement.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
