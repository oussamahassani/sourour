import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'clientList.dart';
import '../providers/client_provider.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00796B);
  static const Color secondaryColor = Color(0xFF004D40);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color textColor = Color(0xFF212121);
  static const Color cardColor = Color(0xFFE0F2F1);
}

class Client extends StatelessWidget {
  final Map<String, dynamic> clientData;
  final String? clientId;
  
  final dynamic onClientChanged;
  
  final dynamic onSave;

 const Client({
  super.key, 
  required this.clientData, 
  this.clientId,
  this.onClientChanged, this.onSave,
  // Supprimez onClientChanged si inutilisé
});

  get id => null;

  get nom => null;

  get adresse => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clientId != null ? 'Modifier Client' : 'Nouveau Client'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (clientId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, Colors.white],
          ),
        ),
        child: DefaultTabController(
          length: 2,
          initialIndex: clientData['type'] == 'Moral' ? 0 : 1,
          child: Column(
            children: [
              TabBar(
                indicatorColor: AppTheme.accentColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.business), text: "Entreprise"),
                  Tab(icon: Icon(Icons.person), text: "Personne Physique"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SignupForm(
                        isEntreprise: true,
                        clientData: clientData,
                        clientId: clientId),
                    SignupForm(
                        isEntreprise: false,
                        clientData: clientData,
                        clientId: clientId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClientList()),
        ),
        icon: const Icon(Icons.list_alt),
        label: const Text("Liste des clients"),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce client ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = Provider.of<ClientProvider>(context, listen: false);
        final success = await provider.deleteClient(clientId!);

        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Client supprimé avec succès')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ClientList()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage ?? 'Erreur lors de la suppression')),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}

class SignupForm extends StatefulWidget {
  final bool isEntreprise;
  final Map<String, dynamic> clientData;
  final String? clientId;

  const SignupForm({
    super.key,
    required this.isEntreprise,
    required this.clientData,
    this.clientId,
  });

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;
  late TextEditingController _entrepriseController;
  late TextEditingController _matriculeController;
  late TextEditingController _cinController;
  late TextEditingController _plafondController;
  late TextEditingController _seuilRemiseController;
  late TextEditingController _commercialAssigneController;
  late bool _retenuSourceC;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final client = widget.clientData;

    _dateController = TextEditingController(text: client['date_creation'] ?? '');
    _nomController = TextEditingController(text: client['nom'] ?? '');
    _prenomController = TextEditingController(text: client['prenom'] ?? '');
    _emailController = TextEditingController(text: client['email'] ?? '');
    _telephoneController =
        TextEditingController(text: client['telephone'] ?? '');
    _adresseController = TextEditingController(text: client['adresse'] ?? '');
    _entrepriseController =
        TextEditingController(text: client['entreprise'] ?? '');
    _matriculeController =
        TextEditingController(text: client['matricule'] ?? '');
    _cinController =
        TextEditingController(text: client['cin']?.toString() ?? '');
    _plafondController = TextEditingController(
        text: client['plafond_credit']?.toString() ?? '0');
    _seuilRemiseController =
        TextEditingController(text: client['seuilRemise']?.toString() ?? '0');
    _commercialAssigneController =
        TextEditingController(text: client['commercial_assigne'] ?? '');
    _retenuSourceC = client['retenuSourceC'] == 1;
    _isActive = client['isActive'] ?? true;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _entrepriseController.dispose();
    _matriculeController.dispose();
    _cinController.dispose();
    _plafondController.dispose();
    _seuilRemiseController.dispose();
    _commercialAssigneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    print('❌ Validation du formulaire échouée');
    return;
  }

  print('✅ Formulaire validé');
  try {
    final clientData = _prepareClientData();
    final provider = Provider.of<ClientProvider>(context, listen: false);

    if (widget.clientId != null) {
      print('🛠️ Mise à jour du client : ${widget.clientId}');
      final success = await provider.updateClient(widget.clientId!, clientData);

      if (!context.mounted) return;

      if (success) {
        _showSuccessMessage('Client modifié avec succès !');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClientList()),
        );
      } else {
        _showErrorMessage(provider.errorMessage ?? 'Erreur lors de la modification');
      }
    } else {
      print('➕ Ajout d\'un nouveau client');
      final success = await provider.addClient(clientData);

      if (!context.mounted) return;

      if (success) {
        _showSuccessMessage('Client créé avec succès !');
        _resetForm();
      } else {
        _showErrorMessage(provider.errorMessage ?? 'Erreur lors de l\'ajout');
      }
    }
  } catch (e) {
    if (!context.mounted) return;
    _showErrorMessage('Erreur inattendue: ${e.toString()}');
  }
}


  Map<String, dynamic> _prepareClientData() {
    return {
      'type': widget.isEntreprise ? 'Moral' : 'Physique',
      'email': _emailController.text.trim(),
      'telephone': _telephoneController.text.trim(),
      'adresse': _adresseController.text.trim(),
      'plafond_credit': double.parse(_plafondController.text),
      'validation_admin': 0,
      'seuilRemise': double.parse(_seuilRemiseController.text),
      'commercial_assigne': _commercialAssigneController.text.trim(),
      'retenuSourceC': _retenuSourceC ? 1 : 0,
      'isActive': _isActive,
      if (widget.isEntreprise) ...{
        'entreprise': _entrepriseController.text.trim(),
        'matricule': _matriculeController.text.trim(),
        'nom': '',
        'prenom': '',
        'cin': null,
      },
      if (!widget.isEntreprise) ...{
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'cin': _cinController.text.isNotEmpty
            ? int.parse(_cinController.text)
            : null,
        'entreprise': '',
        'matricule': '',
      },
      if (_dateController.text.isNotEmpty)
        'date_creation': _dateController.text,
    };
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _dateController.clear();
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();
      _telephoneController.clear();
      _adresseController.clear();
      _entrepriseController.clear();
      _matriculeController.clear();
      _cinController.clear();
      _plafondController.text = '0';
      _seuilRemiseController.text = '0';
      _commercialAssigneController.clear();
      _retenuSourceC = false;
      _isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  widget.clientId != null
                      ? "Modifier ${widget.isEntreprise ? "Entreprise" : "Personne Physique"}"
                      : "Nouvelle ${widget.isEntreprise ? "Entreprise" : "Personne Physique"}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                if (!widget.isEntreprise) ...[
                  _buildTextField(_nomController, 'Nom', icon: Icons.person),
                  _buildTextField(
                      _prenomController, 'Prénom', icon: Icons.person_outline),
                  _buildTextField(_cinController, 'CIN',
                      isNumeric: true, icon: Icons.credit_card, maxLength: 8),
                ] else ...[
                  _buildTextField(
                      _entrepriseController, 'Nom de l\'entreprise',
                      icon: Icons.business),
                  _buildTextField(_matriculeController, 'Matricule fiscale',
                      icon: Icons.receipt),
                ],
                
                _buildTextField(_emailController, 'Email',
                    isEmail: true, icon: Icons.email),
                _buildTextField(_telephoneController, 'Téléphone',
                    isNumeric: true, icon: Icons.phone, maxLength: 15),
                _buildTextField(_adresseController, 'Adresse',
                    icon: Icons.location_on),
                _buildTextField(_plafondController, 'Plafond de crédit',
                    isNumeric: true, icon: Icons.attach_money),
                _buildTextField(_seuilRemiseController, 'Seuil de remise (%)',
                    isNumeric: true, icon: Icons.discount),
                
                _buildTextField(
                  _commercialAssigneController,
                  'Commercial assigné',
                  icon: Icons.person_pin,
                  hintText: 'Entrez l\'identifiant du commercial',
                ),
                
                const SizedBox(height: 16),
                _buildDatePicker(),
                _buildCheckbox("Retenue à la source", _retenuSourceC, (value) {
                  setState(() => _retenuSourceC = value ?? false);
                }),
                _buildCheckbox("Actif", _isActive, (value) {
                  setState(() => _isActive = value ?? true);
                }),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding:  EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                      widget.clientId != null ? 'Modifier' : 'Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumeric = false,
    bool isEmail = false,
    IconData? icon,
    String? hintText,
    int? maxLength,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric
            ? TextInputType.number
            : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(icon, color: AppTheme.primaryColor)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => _validateField(value, label, isNumeric, isEmail),
      ),
    );
  }

  String? _validateField(
      String? value, String label, bool isNumeric, bool isEmail) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (isEmail && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Email invalide';
    }
    if (isNumeric && double.tryParse(value) == null) {
      return 'Valeur numérique requise';
    }
    if (label == 'CIN' && value.length != 8) {
      return 'Le CIN doit contenir 8 chiffres';
    }
    if (label == 'Téléphone' && (value.length < 8 || value.length > 15)) {
      return 'Le téléphone doit contenir entre 8 et 15 chiffres';
    }
    return null;
  }

  Widget _buildDatePicker() {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: "Date de création (optionnel)",
          prefixIcon:
              const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
          filled: true,
          fillColor: Colors.white,
        ),
        readOnly: true,
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _dateController.text.isNotEmpty
                ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              _dateController.text =
                  DateFormat('yyyy-MM-dd').format(pickedDate);
            });
          }
        },
      ),
    );
  }

  Widget _buildCheckbox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
}