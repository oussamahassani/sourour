import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/InterventionReport.dart';
import '../services/intervention_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapports d\'Intervention',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InterventionListScreen(),
    );
  }
}

class InterventionReportForm extends StatefulWidget {
  final InterventionReport? intervention;
  final Function(InterventionReport)? onSave;
  final int? index;

  const InterventionReportForm({
    Key? key,
    this.intervention,
    this.onSave,
    this.index,
  }) : super(key: key);

  @override
  _InterventionReportFormState createState() => _InterventionReportFormState();
}

class _InterventionReportFormState extends State<InterventionReportForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _technicianController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _interventionTypeController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionsTakenController = TextEditingController();
  final TextEditingController _materialsUsedController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _recommendationsController =
      TextEditingController();
  final TextEditingController _clientSignatureController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _clientSatisfied = true;
  bool _isInitialized = false;

  final Color primaryColor = const Color(0xFF009688);
  final Color secondaryColor = const Color(0xFF4DB6AC);
  final Color backgroundColor = const Color(0xFFF6F7F9);
  final Color textColor = const Color(0xFF004D40);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _initializeData() {
    if (widget.intervention != null) {
      _loadInterventionData();
    } else {
      final now = DateTime.now();
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
      _dateController.text = DateFormat('dd/MM/yyyy').format(now);
      _timeController.text = _selectedTime!.format(context);
    }
    setState(() {
      _isInitialized = true;
    });
  }

  void _loadInterventionData() {
    final intervention = widget.intervention!;
    _clientController.text = intervention.clientName ?? '';
    _addressController.text = intervention.address ?? '';
    _technicianController.text = intervention.technicianName ?? '';
    if (intervention.date != null) {
      _dateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(intervention.date!);
      _selectedDate = intervention.date;
    }
    if (intervention.time != null) {
      _timeController.text = intervention.time!.format(context);
      _selectedTime = intervention.time;
    }
    _interventionTypeController.text = intervention.interventionType ?? '';
    _descriptionController.text = intervention.description ?? '';
    _actionsTakenController.text = intervention.actionsTaken ?? '';
    _materialsUsedController.text = intervention.materialsUsed ?? '';
    _durationController.text = intervention.actualDuration ?? '';
    _observationsController.text = intervention.observations ?? '';
    _recommendationsController.text = intervention.recommendations ?? '';
    _clientSignatureController.text = intervention.clientSignature ?? '';
    _clientSatisfied = intervention.clientSatisfied ?? true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveReport() async {
    if (_formKey.currentState!.validate()) {
      final newReport = InterventionReport(
        clientName:
            _clientController.text.trim().isNotEmpty
                ? _clientController.text.trim()
                : "client",
        address:
            _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : "adress",
        technicianName:
            _technicianController.text.trim().isNotEmpty
                ? _technicianController.text.trim()
                : "technicien",
        date: _selectedDate,
        time: _selectedTime,
        interventionType:
            _interventionTypeController.text.trim().isNotEmpty
                ? _interventionTypeController.text.trim()
                : "Reparation",
        description: _descriptionController.text,
        actionsTaken: _actionsTakenController.text,
        materialsUsed: _materialsUsedController.text,
        actualDuration: _durationController.text,
        observations: _observationsController.text,
        recommendations: _recommendationsController.text,
        clientSignature: _clientSignatureController.text,
        clientSatisfied: _clientSatisfied,
      );

      final data = await InterventionService.createReport(newReport);
      if (widget.onSave != null) {
        widget.onSave!(newReport);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rapport enregistré avec succès'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPDFHeader(),
            _buildPDFClientInfo(),
            _buildPDFSection(
              'Description de l\'intervention',
              _descriptionController.text,
            ),
            _buildPDFSection('Actions réalisées', _actionsTakenController.text),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPDFSection(
                    'Matériels utilisés',
                    _materialsUsedController.text,
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: _buildPDFSection(
                    'Durée de l\'intervention',
                    _durationController.text,
                  ),
                ),
              ],
            ),
            _buildPDFSection('Observations', _observationsController.text),
            _buildPDFSection(
              'Recommandations',
              _recommendationsController.text,
            ),
            _buildClientSatisfaction(),
            _buildSignatures(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFHeader() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'RAPPORT D\'INTERVENTION',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(child: pw.Text('LOGO')),
            ),
          ],
        ),
        pw.Divider(color: PdfColors.teal, thickness: 2),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildPDFClientInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.teal50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFInfoRow(
                      'Client:',
                      _clientController.text,
                      bold: true,
                    ),
                    _buildPDFInfoRow('Adresse:', _addressController.text),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPDFInfoRow('Date:', _dateController.text),
                    _buildPDFInfoRow('Heure:', _timeController.text),
                  ],
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.teal),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPDFInfoRow(
                  'Technicien:',
                  _technicianController.text,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildPDFInfoRow(
                  'Type d\'intervention:',
                  _interventionTypeController.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFInfoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSection(String title, String content) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(content),
        ],
      ),
    );
  }

  pw.Widget _buildClientSatisfaction() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Satisfaction client',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Le client est satisfait de l\'intervention: ${_clientSatisfied ? 'Oui' : 'Non'}',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatures() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      margin: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text('Signature du technicien'),
              pw.SizedBox(height: 40),
              pw.Container(width: 150, height: 1, color: PdfColors.black),
              pw.SizedBox(height: 5),
              pw.Text(_technicianController.text),
            ],
          ),
          pw.Column(
            children: [
              pw.Text('Signature du client'),
              pw.SizedBox(height: 40),
              pw.Container(width: 150, height: 1, color: PdfColors.black),
              pw.SizedBox(height: 5),
              pw.Text(
                _clientSignatureController.text.isNotEmpty
                    ? _clientSignatureController.text
                    : _clientController.text,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: secondaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rapport d\'Intervention'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePDF,
              tooltip: 'Générer PDF',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveReport,
              tooltip: 'Enregistrer',
            ),
          ],
        ),
        body: Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInterventionDetailsSection(),
                  const SizedBox(height: 16),
                  _buildInterventionDetailsSection(),
                  const SizedBox(height: 16),
                  _buildObservationsSection(),
                  const SizedBox(height: 16),
                  _buildClientSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const InterventionListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('Voir la liste des interventions'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionDetailsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de l\'intervention',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _descriptionController,
              'Description',
              Icons.description,
              false,
              maxLines: 3,
            ),
            _buildTextField(
              _actionsTakenController,
              'Actions réalisées',
              Icons.build,
              false,
              maxLines: 3,
            ),
            _buildTextField(
              _materialsUsedController,
              'Matériels utilisés',
              Icons.inventory,
              false,
              maxLines: 2,
            ),
            _buildTextField(
              _durationController,
              'Durée de l\'intervention',
              Icons.timer,
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observations et recommandations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _observationsController,
              'Observations',
              Icons.visibility,
              false,
              maxLines: 3,
            ),
            _buildTextField(
              _recommendationsController,
              'Recommandations',
              Icons.recommend,
              false,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Satisfaction client et signatures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Client satisfait de l\'intervention'),
              value: _clientSatisfied,
              activeColor: primaryColor,
              onChanged: (bool value) {
                setState(() {
                  _clientSatisfied = value;
                });
              },
            ),
            _buildTextField(
              _clientSignatureController,
              'Nom du signataire (client)',
              Icons.person,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _saveReport,
        icon: const Icon(Icons.save),
        label: const Text('Enregistrer le rapport'),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        maxLines: maxLines,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Ce champ est obligatoire';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Date',
        prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une date';
        }
        return null;
      },
    );
  }

  Widget _buildTimePickerField() {
    return TextFormField(
      controller: _timeController,
      decoration: InputDecoration(
        labelText: 'Heure',
        prefixIcon: Icon(Icons.access_time, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      readOnly: true,
      onTap: () => _selectTime(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une heure';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _clientController.dispose();
    _addressController.dispose();
    _technicianController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _interventionTypeController.dispose();
    _descriptionController.dispose();
    _actionsTakenController.dispose();
    _materialsUsedController.dispose();
    _durationController.dispose();
    _observationsController.dispose();
    _recommendationsController.dispose();
    _clientSignatureController.dispose();
    super.dispose();
  }
}

class InterventionListScreen extends StatefulWidget {
  const InterventionListScreen({Key? key}) : super(key: key);

  @override
  _InterventionListScreenState createState() => _InterventionListScreenState();
}

class _InterventionListScreenState extends State<InterventionListScreen> {
  List<InterventionReport> _interventions = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Color primaryColor = const Color(0xFF009688);
  final Color secondaryColor = const Color(0xFF4DB6AC);
  final Color backgroundColor = const Color(0xFFF6F7F9);

  @override
  void initState() {
    super.initState();
    // Ajout de données de démonstration
    _loadData();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadData() async {
    List<InterventionReport> intervention =
        await InterventionService.fetchAllRepport();

    setState(() {
      _interventions = intervention;
    });
  }

  void _addOrUpdateIntervention(InterventionReport intervention, [int? index]) {
    setState(() {
      if (index != null) {
        _interventions[index] = intervention;
      } else {
        _interventions.add(intervention);
      }
    });
  }

  void _deleteIntervention(int index) async {
    String id = _interventions[index].id ?? "";
    if (id != "") {
      await InterventionService.deleteRepport(id);
    }
    setState(() {
      _interventions.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rapport supprimé avec succès'),
        backgroundColor: primaryColor,
      ),
    );
  }

  List<InterventionReport> get _filteredInterventions {
    if (_searchQuery.isEmpty) {
      return _interventions;
    }
    return _interventions.where((intervention) {
      return intervention.clientName?.toLowerCase().contains(_searchQuery) ??
          false;
    }).toList();
  }

  Future<void> _generatePDF(InterventionReport intervention) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              'RAPPORT D\'INTERVENTION',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
            pw.Divider(color: PdfColors.teal, thickness: 2),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal50,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.teal),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildPDFInfoRow(
                              'Client:',
                              intervention.clientName ?? '',
                              bold: true,
                            ),
                            _buildPDFInfoRow(
                              'Adresse:',
                              intervention.address ?? '',
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildPDFInfoRow(
                              'Date:',
                              intervention.date != null
                                  ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(intervention.date!)
                                  : '',
                            ),
                            _buildPDFInfoRow(
                              'Heure:',
                              intervention.time?.format(
                                    context as BuildContext,
                                  ) ??
                                  '',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(color: PdfColors.teal),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildPDFInfoRow(
                          'Technicien:',
                          intervention.technicianName ?? '',
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        child: _buildPDFInfoRow(
                          'Type d\'intervention:',
                          intervention.interventionType ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _buildPDFSection(
              'Description de l\'intervention',
              intervention.description ?? '',
            ),
            _buildPDFSection(
              'Actions réalisées',
              intervention.actionsTaken ?? '',
            ),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildPDFSection(
                    'Matériels utilisés',
                    intervention.materialsUsed ?? '',
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: _buildPDFSection(
                    'Durée de l\'intervention',
                    intervention.actualDuration ?? '',
                  ),
                ),
              ],
            ),
            _buildPDFSection('Observations', intervention.observations ?? ''),
            _buildPDFSection(
              'Recommandations',
              intervention.recommendations ?? '',
            ),
            _buildClientSatisfaction(intervention),
            _buildSignatures(intervention),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFInfoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal900,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFSection(String title, String content) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(content),
        ],
      ),
    );
  }

  pw.Widget _buildClientSatisfaction(InterventionReport intervention) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Satisfaction client',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Le client est satisfait de l\'intervention: ${intervention.clientSatisfied ?? true ? 'Oui' : 'Non'}',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatures(InterventionReport intervention) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      margin: const pw.EdgeInsets.only(top: 20),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.teal),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text('Signature du technicien'),
              pw.SizedBox(height: 40),
              pw.Container(width: 150, height: 1, color: PdfColors.black),
              pw.SizedBox(height: 5),
              pw.Text(intervention.technicianName ?? ''),
            ],
          ),
          pw.Column(
            children: [
              pw.Text('Signature du client'),
              pw.SizedBox(height: 40),
              pw.Container(width: 150, height: 1, color: PdfColors.black),
              pw.SizedBox(height: 5),
              pw.Text(
                intervention.clientSignature?.isNotEmpty == true
                    ? intervention.clientSignature!
                    : intervention.clientName ?? '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showInterventionDetails(InterventionReport intervention) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Détails de l\'intervention',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Client:', intervention.clientName ?? ''),
                  _buildDetailRow('Adresse:', intervention.address ?? ''),
                  _buildDetailRow(
                    'Technicien:',
                    intervention.technicianName ?? '',
                  ),
                  _buildDetailRow(
                    'Date:',
                    intervention.date != null
                        ? DateFormat('dd/MM/yyyy').format(intervention.date!)
                        : '',
                  ),
                  _buildDetailRow(
                    'Heure:',
                    intervention.time?.format(context) ?? '',
                  ),
                  _buildDetailRow(
                    'Type d\'intervention:',
                    intervention.interventionType ?? '',
                  ),
                  _buildDetailRow(
                    'Description:',
                    intervention.description ?? '',
                  ),
                  _buildDetailRow(
                    'Actions réalisées:',
                    intervention.actionsTaken ?? '',
                  ),
                  _buildDetailRow(
                    'Matériels utilisés:',
                    intervention.materialsUsed ?? '',
                  ),
                  _buildDetailRow('Durée:', intervention.actualDuration ?? ''),
                  _buildDetailRow(
                    'Observations:',
                    intervention.observations ?? '',
                  ),
                  _buildDetailRow(
                    'Recommandations:',
                    intervention.recommendations ?? '',
                  ),
                  _buildDetailRow(
                    'Satisfaction client:',
                    intervention.clientSatisfied ?? true ? 'Oui' : 'Non',
                  ),
                  _buildDetailRow(
                    'Signature client:',
                    intervention.clientSignature?.isNotEmpty == true
                        ? intervention.clientSignature!
                        : intervention.clientName ?? '',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Rapports'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => InterventionReportForm(
                        onSave:
                            (intervention) =>
                                _addOrUpdateIntervention(intervention),
                      ),
                ),
              );
            },
            tooltip: 'Ajouter un rapport',
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher par client',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredInterventions.isEmpty
                      ? const Center(child: Text('Aucun rapport trouvé'))
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredInterventions.length,
                        itemBuilder: (context, index) {
                          final intervention = _filteredInterventions[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                intervention.clientName ?? 'Sans nom',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                'Date: ${intervention.date != null ? DateFormat('dd/MM/yyyy').format(intervention.date!) : 'N/A'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info,
                                      color: Colors.green,
                                    ),
                                    onPressed:
                                        () => _showInterventionDetails(
                                          intervention,
                                        ),
                                    tooltip: 'Voir les détails',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => InterventionReportForm(
                                                intervention: intervention,
                                                onSave:
                                                    (updatedIntervention) =>
                                                        _addOrUpdateIntervention(
                                                          updatedIntervention,
                                                          index,
                                                        ),
                                                index: index,
                                              ),
                                        ),
                                      );
                                    },
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _generatePDF(intervention),
                                    tooltip: 'Générer PDF',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteIntervention(index),
                                    tooltip: 'Supprimer',
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
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
