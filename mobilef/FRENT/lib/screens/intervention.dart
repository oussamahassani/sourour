import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/Client.dart';
import '../services/client_service.dart';
import '../services/intervention_service.dart';
import '../models/Intervention.dart';

class InterventionApp extends StatelessWidget {
  const InterventionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion d\'Interventions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: InterventionScreen(intervention: Intervention()),
    );
  }
}

class InterventionScreen extends StatefulWidget {
  final Intervention intervention;

  const InterventionScreen({Key? key, required this.intervention})
    : super(key: key);

  @override
  _InterventionScreenState createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen> {
  final _formKey = GlobalKey<FormState>();
  late Intervention _intervention;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isLoading = false;

  // Clients data - exemple avec quelques clients
  List<Client> _clients = [];

  Client? _selectedClient;

  final List<String> _interventionTypes = [
    'Installation',
    'Entretien',
    'Réparation',
    'Dépannage',
    'Contrôle périodique',
    'Mise en service',
    'Formation',
    'Autre',
  ];

  @override
  void initState() {
    _loadDevis();
    super.initState();
    _intervention = widget.intervention;
    // Générer un numéro de référence par défaut
    _intervention.referenceNumber =
        'INT-${DateFormat('yyyyMMdd').format(DateTime.now())}-${UniqueKey().toString().substring(0, 4)}';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _loadDevis() async {
    ClientService.fetchClients().then((result) {
      setState(() {
        _clients = result;
      });
    });
  }

  void _updateClientFields(Client client) {
    setState(() {
      _intervention.clientId = client.id;
      _intervention.clientName = client.nom;
      _intervention.address = client.adresse;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _intervention.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.light(primary: Colors.teal),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _intervention.date = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _intervention.time ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.light(primary: Colors.teal),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _intervention.time = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(
              'RAPPORT D\'INTERVENTION',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Header(level: 1, child: pw.Text('Informations sur le client')),
            _buildPdfInfoSection([
              ['Nom du client / entreprise', _intervention.clientName],
              ['Adresse', _intervention.address],
              ['Téléphone', _intervention.phone],
              ['Email', _intervention.email],
              ['Personne de contact', _intervention.contactPerson],
            ]),

            pw.SizedBox(height: 20),

            pw.Header(
              level: 1,
              child: pw.Text('Informations sur l\'intervention'),
            ),
            _buildPdfInfoSection([
              ['Numéro d\'intervention', _intervention.referenceNumber],
              ['Date', _dateController.text],
              ['Heure', _timeController.text],
              ['Type d\'intervention', _intervention.interventionType],
              ['Durée estimée', _intervention.estimatedDuration],
              ['Durée réelle', _intervention.actualDuration],
              ['Technicien', _intervention.technicianName],
              ['Adresse du technicien', _intervention.technicianAddress],
            ]),
          ];
        },
      ),
    );

    try {
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/intervention_${_intervention.referenceNumber}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF généré avec succès: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  pw.Widget _buildPdfInfoSection(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children:
          data.map((row) {
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    row[0],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(row[1]),
                ),
              ],
            );
          }).toList(),
    );
  }

  Future<void> _saveIntervention() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await InterventionService.createIntervention(_intervention);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intervention enregistrée avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      await _generatePdf();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Intervention'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isLoading ? null : _generatePdf,
            tooltip: 'Générer PDF',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informations sur le client'),
                        _buildClientInfoFields(),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Informations sur l\'intervention'),
                        _buildInterventionInfoFields(),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveIntervention,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'ENREGISTRER L\'INTERVENTION',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildClientInfoFields() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              decoration: const InputDecoration(
                labelText: 'Sélectionnez un client *',
                prefixIcon: Icon(Icons.business),
              ),
              value: _selectedClient,
              items:
                  _clients.map((client) {
                    return DropdownMenuItem<Client>(
                      value: client,
                      child: Text(client.nom),
                    );
                  }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un client';
                }
                return null;
              },
              onChanged: (Client? newValue) {
                setState(() {
                  _selectedClient = newValue;
                  if (newValue != null) {
                    _updateClientFields(newValue);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Adresse d\'intervention *',
                prefixIcon: Icon(Icons.location_on),
              ),
              initialValue: _intervention.address,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'adresse';
                }
                return null;
              },
              onSaved: (value) => _intervention.address = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                prefixIcon: Icon(Icons.phone),
              ),
              initialValue: _intervention.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le numéro de téléphone';
                }
                return null;
              },
              onSaved: (value) => _intervention.phone = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              initialValue: _intervention.email,
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _intervention.email = value ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Personne de contact sur place',
                prefixIcon: Icon(Icons.person),
              ),
              onSaved: (value) => _intervention.contactPerson = value ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionInfoFields() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Numéro d\'intervention / Référence *',
                prefixIcon: Icon(Icons.tag),
              ),
              initialValue: _intervention.referenceNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le numéro d\'intervention';
                }
                return null;
              },
              onSaved: (value) => _intervention.referenceNumber = value!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une date';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Heure *',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une heure';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type d\'intervention *',
                prefixIcon: Icon(Icons.category),
              ),
              value:
                  _intervention.interventionType.isNotEmpty
                      ? _intervention.interventionType
                      : null,
              items:
                  _interventionTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un type d\'intervention';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _intervention.interventionType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Durée estimée',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    onSaved:
                        (value) =>
                            _intervention.estimatedDuration = value ?? '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Durée réelle',
                      prefixIcon: Icon(Icons.timer_off),
                    ),
                    onSaved:
                        (value) => _intervention.actualDuration = value ?? '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nom du technicien *',
                prefixIcon: Icon(Icons.engineering),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du technicien';
                }
                return null;
              },
              onSaved: (value) => _intervention.technicianName = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Adresse du technicien',
                prefixIcon: Icon(Icons.home),
              ),
              onSaved: (value) => _intervention.technicianAddress = value ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
