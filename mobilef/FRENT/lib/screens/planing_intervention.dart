import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'intervention.dart';

// Modèles de données
class Client {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;

  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });
}

class Intervention {
  String id = UniqueKey().toString();
  String clientId = '';
  String clientName = '';
  String address = '';
  String phone = '';
  String email = '';
  String contactPerson = '';
  String referenceNumber = '';
  DateTime? date;
  TimeOfDay? time;
  String interventionType = '';
  String estimatedDuration = '';
  String actualDuration = '';
  String technicianName = '';
  String technicianAddress = '';
  bool isCompleted = false;
  String notes = '';

  Intervention({this.isCompleted = false});

  String get formattedDate =>
      date != null ? DateFormat('dd/MM/yyyy').format(date!) : 'Non définie';

  // Fixed formattedTime getter
  String get formattedTime => time != null
      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
      : 'Non définie';
}

class InterventionListApp extends StatelessWidget {
  const InterventionListApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Interventions',
      theme: ThemeData(
        primaryColor: Colors.teal[800],
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.teal,
          backgroundColor: Colors.grey[100],
        ).copyWith(secondary: Colors.teal),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.teal[900],
                displayColor: Colors.blueGrey[900],
              ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.blueGrey[400],
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400),
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.teal, width: 2),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blueGrey[900]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.blueGrey[600]),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const InterventionListScreen(),
    );
  }
}

class InterventionListScreen extends StatefulWidget {
  const InterventionListScreen({Key? key}) : super(key: key);

  @override
  _InterventionListScreenState createState() => _InterventionListScreenState();
}

class _InterventionListScreenState extends State<InterventionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Intervention> _interventions = [];
  List<Intervention> _filteredInterventions = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSampleInterventions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSampleInterventions() {
    setState(() {
      _interventions = [
        Intervention()
          ..clientName = "Client A"
          ..referenceNumber = "INT-20230001"
          ..date = DateTime.now().add(const Duration(days: 2))
          ..time = TimeOfDay(hour: 9, minute: 0)
          ..interventionType = "Installation"
          ..isCompleted = false,
        Intervention()
          ..clientName = "Client B"
          ..referenceNumber = "INT-20230002"
          ..date = DateTime.now().add(const Duration(days: -1))
          ..time = TimeOfDay(hour: 14, minute: 30)
          ..interventionType = "Réparation"
          ..isCompleted = true,
        Intervention()
          ..clientName = "Client C"
          ..referenceNumber = "INT-20230003"
          ..date = DateTime.now().add(const Duration(days: 5))
          ..time = TimeOfDay(hour: 10, minute: 0)
          ..interventionType = "Entretien"
          ..isCompleted = false,
        Intervention()
          ..clientName = "Client D"
          ..referenceNumber = "INT-20230004"
          ..date = DateTime.now().add(const Duration(days: -3))
          ..time = TimeOfDay(hour: 11, minute: 0)
          ..interventionType = "Contrôle"
          ..isCompleted = true,
      ];
      _filterInterventions();
    });
  }

  void _filterInterventions() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredInterventions = _interventions.where((intervention) {
        final matchesSearch = intervention.clientName.toLowerCase().contains(searchQuery) ||
            intervention.referenceNumber.toLowerCase().contains(searchQuery) ||
            intervention.interventionType.toLowerCase().contains(searchQuery);
        if (_tabController.index == 0) {
          return matchesSearch && !intervention.isCompleted;
        } else {
          return matchesSearch && intervention.isCompleted;
        }
      }).toList();
    });
  }

  void _deleteIntervention(String id) {
    setState(() {
      _interventions.removeWhere((intervention) => intervention.id == id);
      _filterInterventions();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Intervention supprimée', style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _markAsCompleted(String id) {
    setState(() {
      final intervention = _interventions.firstWhere((i) => i.id == id);
      intervention.isCompleted = true;
      _filterInterventions();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Intervention marquée comme terminée', style: GoogleFonts.inter()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToEditIntervention(Intervention intervention) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterventionApp(),
      ),
    ).then((_) => setState(() => _filterInterventions()));
  }

  void _navigateToAddIntervention() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterventionApp(),
      ),
    ).then((_) => setState(() => _filterInterventions()));
  }

  void _showInterventionDetails(Intervention intervention) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Détails de l\'intervention',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.blueGrey[900],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Client', intervention.clientName),
              _buildDetailRow('Référence', intervention.referenceNumber),
              _buildDetailRow('Date', intervention.formattedDate),
              _buildDetailRow('Heure', intervention.formattedTime),
              _buildDetailRow('Type', intervention.interventionType),
              _buildDetailRow('Technicien', intervention.technicianName.isEmpty ? 'Non assigné' : intervention.technicianName),
              _buildDetailRow('Statut', intervention.isCompleted ? 'Terminée' : 'Planifiée'),
              if (intervention.notes.isNotEmpty)
                _buildDetailRow('Notes', intervention.notes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.inter(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.teal[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(color: Colors.teal[800]),
            ),
          ),
        ],
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Center(
        child: Text(
          'Gestion des Interventions',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center, // Ensures text is centered
        ),
      ),
      backgroundColor: Colors.teal,
      elevation: 2,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            text: 'À faire',
            icon: Icon(Icons.list_alt),
            iconMargin: EdgeInsets.only(bottom: 4), // Optional: adjusts spacing
          ),
          Tab(
            text: 'Historique',
            icon: Icon(Icons.history),
            iconMargin: EdgeInsets.only(bottom: 4), // Optional: adjusts spacing
          ),
        ],
        onTap: (index) => _filterInterventions(),
        labelColor: Colors.white, // Sets tab text color to white when selected
        unselectedLabelColor: Colors.white.withOpacity(0.7), // Unselected tab text in lighter white
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher une intervention',
              prefixIcon: Icon(Icons.search, color: Colors.teal[600]),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.teal[600]),
                onPressed: () {
                  _searchController.clear();
                  _filterInterventions();
                },
              ),
            ),
            onChanged: (value) => _filterInterventions(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInterventionList(false),
              _buildInterventionList(true),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToAddIntervention,
      child: const Icon(Icons.add),
      tooltip: 'Ajouter une intervention',
    ),
  );
}
  Widget _buildInterventionList(bool showCompleted) {
    if (_filteredInterventions.isEmpty) {
      return Center(
        child: Text(
          showCompleted
              ? 'Aucune intervention terminée'
              : 'Aucune intervention planifiée',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.blueGrey[400],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredInterventions.length,
      itemBuilder: (context, index) {
        final intervention = _filteredInterventions[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              intervention.clientName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.teal[900],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Réf: ${intervention.referenceNumber}',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                ),
                Text(
                  'Type: ${intervention.interventionType}',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                ),
                Text(
                  'Date: ${intervention.formattedDate} à ${intervention.formattedTime}',
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.teal[600]),
                  onPressed: () => _showInterventionDetails(intervention),
                  tooltip: 'Voir les détails',
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.teal),
                  onPressed: () => _navigateToEditIntervention(intervention),
                  tooltip: 'Modifier',
                ),
                if (!showCompleted)
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.teal),
                    onPressed: () => _markAsCompleted(intervention.id),
                    tooltip: 'Marquer comme terminé',
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.teal),
                  onPressed: () => _deleteIntervention(intervention.id),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}