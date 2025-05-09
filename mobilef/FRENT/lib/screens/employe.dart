import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_rh_service.dart';
import '../models/Employee.dart';

class EmployeeManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Employés',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.teal, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
      home: EmployeeForm(),
    );
  }
}

// Modèle d'employé

List<Employee> dummyEmployees = [];

// Liste d'employés pour la démonstration
/*List<Employee> dummyEmployees = [
  Employee(
    id: '1',
    nom: 'Dupont',
    prenom: 'Jean',
    age: 35,
    telephone: '+21622334455',
    adresse: '15 Avenue Habib Bourguiba, Tunis',
    email: 'jean.dupont@gmail.com',
    dateEmbauche: '2022-03-15',
    genre: 'H',
    situationFamiliale: 'Marié(e)',
    poste: 'Technicien',
    privilege: 'Niveau 2',
  ),
  Employee(
    id: '2',
    nom: 'Ben Salah',
    prenom: 'Sarra',
    age: 28,
    telephone: '+21699887766',
    adresse: '7 Rue Ibn Khaldoun, Sousse',
    email: 'sarra.bensalah@gmail.com',
    dateEmbauche: '2023-06-10',
    genre: 'F',
    situationFamiliale: 'Célibataire',
    poste: 'Responsable financiére',
    privilege: 'Niveau 3',
  ),
  Employee(
    id: '3',
    nom: 'Malouli',
    prenom: 'Karim',
    age: 42,
    telephone: '+21655443322',
    adresse: '23 Avenue Mohamed V, Sfax',
    email: 'karim.malouli@gmail.com',
    dateEmbauche: '2020-11-20',
    genre: 'H',
    situationFamiliale: 'Marié(e)',
    poste: 'Chef d\'équipe',
    privilege: 'Niveau 4',
  ),
];
*/
class EmployeeForm extends StatefulWidget {
  final Employee? employeeToEdit;

  EmployeeForm({this.employeeToEdit});

  @override
  _EmployeeFormState createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _privilegeController = TextEditingController();

  String? _selectedPost;
  String _gender = "H";
  String _familyStatus = "Célibataire";
  bool _isUser = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _posts = [
    "Technicien",
    "Responsable d'achat",
    "Responsable financiére",
    "Commercial",
    "Frigoriste",
    "Chef d'équipe",
  ];

  Future<void> loadEmployees() async {
    final employees =
        await UserRhService.fetchEmployees(); // Doit renvoyer un Future<List<Employee>>
    setState(() {
      dummyEmployees = employees;
    });
  }

  final List<String> _privileges = [
    "Niveau 1",
    "Niveau 2",
    "Niveau 3",
    "Niveau 4",
    "Admin",
  ];

  @override
  void initState() {
    super.initState();
    loadEmployees();
    if (widget.employeeToEdit != null) {
      _nameController.text = widget.employeeToEdit?.fullname ?? '';
      _surnameController.text = widget.employeeToEdit?.prenom ?? '';
      _ageController.text =
          widget.employeeToEdit?.age?.toString() ??
          ''; // Ensure 'age' is not null and convert to String
      _phoneController.text = widget.employeeToEdit?.telephone ?? '';
      _addressController.text = widget.employeeToEdit?.adresse ?? '';
      _emailController.text = widget.employeeToEdit?.email ?? '';
      _dateController.text = widget.employeeToEdit?.dateEmbauche ?? '';
      _gender = widget.employeeToEdit?.genre ?? '';
      _familyStatus = widget.employeeToEdit?.situationFamiliale ?? '';
      _selectedPost = widget.employeeToEdit?.poste ?? '';
      _privilegeController.text = widget.employeeToEdit?.privilege ?? '';
    } else {
      _privilegeController.text = "Niveau 1";
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employé enregistré avec succès'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Ajouter logique de sauvegarde ici

      if (widget.employeeToEdit == null) {
        final newEmployee = Employee(
          id: (dummyEmployees.length + 1).toString(),
          fullname: _nameController.text,
          prenom: _surnameController.text,
          age: int.parse(_ageController.text),
          telephone: _phoneController.text,
          adresse: _addressController.text,
          email: _emailController.text,
          dateEmbauche: _dateController.text,
          genre: _gender,
          situationFamiliale: _familyStatus,
          poste: _selectedPost ?? _posts.first,
          privilege: _privilegeController.text,
        );

        try {
          await UserRhService.createEmployee(newEmployee); // Appel à l'API
          setState(() {
            dummyEmployees.add(newEmployee); // Ajoute localement après succès
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Employé ajouté avec succès')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
          );
        }
      }

      // Retourner à la liste après sauvegarde
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmployeeListScreen()),
      );
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est obligatoire';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }
    if (!value.startsWith('+')) {
      return 'Le numéro doit commencer par +';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employeeToEdit == null
              ? "Ajout d'un Employé"
              : "Modification d'un Employé",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
            fontSize: 18, // Optional: adjust font size
          ),
        ),
        backgroundColor: Colors.teal, // AppBar background color
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // Color for back button and action icons
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmployeeListScreen()),
              );
            },
            tooltip: "Liste des employés",
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.teal,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Nom",
                            prefixIcon: Icon(Icons.person, color: Colors.teal),
                          ),
                          validator: _validateRequired,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            labelText: "Prénom",
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.teal,
                            ),
                          ),
                          validator: _validateRequired,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Âge",
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Colors.teal,
                      ),
                    ),
                    validator: _validateRequired,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Téléphone",
                      hintText: "+216",
                      prefixIcon: Icon(Icons.phone, color: Colors.teal),
                    ),
                    validator: _validatePhone,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: "Adresse",
                      prefixIcon: Icon(Icons.home, color: Colors.teal),
                    ),
                    validator: _validateRequired,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "exemple@gmail.com",
                      prefixIcon: Icon(Icons.email, color: Colors.teal),
                    ),
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: "Date d'embauche",
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        color: Colors.teal,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.teal,
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: _validateRequired,
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Genre",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Row(
                            children: [
                              Radio(
                                value: "H",
                                groupValue: _gender,
                                activeColor: Colors.teal,
                                onChanged:
                                    (value) => setState(() => _gender = value!),
                              ),
                              Text("Homme"),
                              SizedBox(width: 20),
                              Radio(
                                value: "F",
                                groupValue: _gender,
                                activeColor: Colors.teal,
                                onChanged:
                                    (value) => setState(() => _gender = value!),
                              ),
                              Text("Femme"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Situation familiale",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          Row(
                            children: [
                              Radio(
                                value: "Marié(e)",
                                groupValue: _familyStatus,
                                activeColor: Colors.teal,
                                onChanged:
                                    (value) =>
                                        setState(() => _familyStatus = value!),
                              ),
                              Text("Marié(e)"),
                              SizedBox(width: 20),
                              Radio(
                                value: "Célibataire",
                                groupValue: _familyStatus,
                                activeColor: Colors.teal,
                                onChanged:
                                    (value) =>
                                        setState(() => _familyStatus = value!),
                              ),
                              Text("Célibataire"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Poste",
                      prefixIcon: Icon(Icons.work, color: Colors.teal),
                    ),
                    value: _selectedPost ?? _posts.first,
                    items:
                        _posts
                            .map(
                              (post) => DropdownMenuItem(
                                value: post,
                                child: Text(post),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPost = value.toString();
                        _isUser = _selectedPost == "Utilisateur";
                      });
                    },
                    validator:
                        (value) =>
                            value == null
                                ? 'Veuillez sélectionner un poste'
                                : null,
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveEmployee,
                          icon: Icon(Icons.save),
                          label: Text("Enregistrer"),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeListScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.list),
                          label: Text("Liste employés"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String _searchQuery = '';

  void _deleteEmployee(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de vouloir supprimer cet employé ?"),
          actions: [
            TextButton(
              child: Text("Annuler", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Supprimer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  dummyEmployees.removeWhere((employee) => employee.id == id);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Employé supprimé avec succès'),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) {
      return dummyEmployees;
    }

    return dummyEmployees.where((employee) {
      return (employee?.fullname?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          ) ||
          (employee?.prenom?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          ) ||
          (employee?.poste?.toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des Employés",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmployeeForm()),
              );
            },
            tooltip: "Ajouter un employé",
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
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Rechercher un employé...",
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredEmployees.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied,
                              size: 80,
                              color: Colors.teal.shade200,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Aucun employé trouvé",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        padding: EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                child: Text(
                                  "${employee.fullname}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                "${employee.fullname}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(
                                    employee.poste ?? "",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(employee.email ?? ""),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.visibility,
                                      color: Colors.teal,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EmployeeDetailScreen(
                                                employee: employee,
                                              ),
                                        ),
                                      );
                                    },
                                    tooltip: "Détails",
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EmployeeForm(
                                                employeeToEdit: employee,
                                              ),
                                        ),
                                      );
                                    },
                                    tooltip: "Modifier",
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () =>
                                            _deleteEmployee(employee.id ?? ""),
                                    tooltip: "Supprimer",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmployeeForm()),
          );
        },
        tooltip: "Ajouter un employé",
      ),
    );
  }
}

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  EmployeeDetailScreen({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails de l'employé",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeForm(employeeToEdit: employee),
                ),
              );
            },
            tooltip: "Modifier",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal,
                        child: Text(
                          "${employee.fullname}",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        " ${employee.fullname}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      Text(
                        employee.poste ?? "",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _buildDetailCard(
                  icon: Icons.person,
                  title: "Informations personnelles",
                  content: [
                    _buildDetailItem("Âge", "${employee.age} ans"),
                    _buildDetailItem(
                      "Genre",
                      employee.genre == "H" ? "Homme" : "Femme",
                    ),
                    _buildDetailItem(
                      "Situation familiale",
                      employee.situationFamiliale ?? "",
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  icon: Icons.contact_phone,
                  title: "Coordonnées",
                  content: [
                    _buildDetailItem("Téléphone", employee.telephone ?? ""),
                    _buildDetailItem("Email", employee.email ?? ""),
                    _buildDetailItem("Adresse", employee.adresse ?? ""),
                  ],
                ),
                SizedBox(height: 16),
                _buildDetailCard(
                  icon: Icons.work,
                  title: "Informations professionnelles",
                  content: [
                    _buildDetailItem(
                      "Date d'embauche",
                      employee.dateEmbauche ?? "",
                    ),
                    _buildDetailItem("Privilège", employee.privilege ?? ""),
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Retour à la liste"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
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

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey.shade800)),
          ),
        ],
      ),
    );
  }
}
