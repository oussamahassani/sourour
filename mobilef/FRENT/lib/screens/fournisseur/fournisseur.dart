import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/fournisseur.dart';
import '../../providers/fournisseur_provider.dart';
import 'listFournisseur.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00796B);
  static const Color secondaryColor = Color(0xFF004D40);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color textColor = Color(0xFF212121);
  static const Color cardColor = Color(0xFFE0F2F1);
  static const Color errorColor = Color(0xFFC62828);
}

class FournisseurScreen extends StatefulWidget {
  final Map<String, dynamic> fournisseurData;
  final String? fournisseurId;

  const FournisseurScreen({
    super.key,
    required this.fournisseurData,
    this.fournisseurId,
  });

  @override
  State<FournisseurScreen> createState() => _FournisseurScreenState();
}

class _FournisseurScreenState extends State<FournisseurScreen> {
  late bool _isEntreprise;

  @override
  void initState() {
    super.initState();
    _isEntreprise = widget.fournisseurData['type'] == 'Entreprise';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fournisseurId != null 
            ? 'Modifier Fournisseur' 
            : 'Nouveau Fournisseur'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (widget.fournisseurId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Supprimer',
            ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              initialIndex: _isEntreprise ? 0 : 1,
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        FournisseurForm(
                          isEntreprise: true,
                          fournisseurData: widget.fournisseurData,
                          fournisseurId: widget.fournisseurId,
                        ),
                        FournisseurForm(
                          isEntreprise: false,
                          fournisseurData: widget.fournisseurData,
                          fournisseurId: widget.fournisseurId,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _buildTabBar() {
    return TabBar(
      indicatorColor: AppTheme.accentColor,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: const [
        Tab(icon: Icon(Icons.business), text: 'Entreprise'),
        Tab(icon: Icon(Icons.person), text: 'Personne'),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FournisseurList()),
      ),
      icon: const Icon(Icons.list_alt),
      label: const Text("Liste des fournisseurs"),
      backgroundColor: AppTheme.primaryColor,
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer ce fournisseur ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Supprimer', 
                style: TextStyle(color: AppTheme.errorColor)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteFournisseur(context);
    }
  }

  Future<void> _deleteFournisseur(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<FournisseurProvider>(context, listen: false);

    try {
      await provider.deleteFournisseur(widget.fournisseurId!);
      
      if (!context.mounted) return;
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Fournisseur supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FournisseurList()),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class FournisseurForm extends StatefulWidget {
  final bool isEntreprise;
  final Map<String, dynamic> fournisseurData;
  final String? fournisseurId;

  const FournisseurForm({
    super.key,
    required this.isEntreprise,
    required this.fournisseurData,
    this.fournisseurId,
  });

  @override
  State<FournisseurForm> createState() => _FournisseurFormState();
}

class _FournisseurFormState extends State<FournisseurForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  bool _isLoading = false;
  
  bool get isPhone => false;
  

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final data = widget.fournisseurData;
    _controllers = {
      'nom': TextEditingController(text: data['nom'] ?? ''),
      'prenom': TextEditingController(text: data['prenom'] ?? ''),
      'email': TextEditingController(text: data['email'] ?? ''),
      'telephone': TextEditingController(text: data['telephone'] ?? ''),
      'adresse': TextEditingController(text: data['adresse'] ?? ''),
      'entreprise': TextEditingController(text: data['entreprise'] ?? ''),
      'matricule': TextEditingController(text: data['matricule'] ?? ''),
      'evaluation': TextEditingController(text: data['evaluation']?.toString() ?? '0'),
      'delaiLivraisonMoyen': TextEditingController(text: data['delaiLivraisonMoyen']?.toString() ?? '0'),
      'conditionsPaiement': TextEditingController(text: data['conditionsPaiement'] ?? ''),
      'notes': TextEditingController(text: data['notes'] ?? ''),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
                _buildTitle(),
                const SizedBox(height: 20),
                
                if (widget.isEntreprise) ...[
                  _buildTextField('entreprise', 'Nom de l\'entreprise', icon: Icons.business),
                  _buildTextField('matricule', 'Matricule fiscale', icon: Icons.receipt),
                ] else ...[
                  _buildTextField('nom', 'Nom', icon: Icons.person),
                  _buildTextField('prenom', 'Prénom', icon: Icons.person_outline),
                ],
                
                _buildTextField('email', 'Email', isEmail: true, icon: Icons.email),
                _buildTextField('telephone', 'Téléphone', isPhone: true, icon: Icons.phone),
                _buildTextField('adresse', 'Adresse', icon: Icons.location_on),
                _buildTextField(
                  'evaluation', 
                  'Évaluation (0-10)', 
                  isNumeric: true,
                  minValue: 0,
                  maxValue: 10,
                  icon: Icons.star,
                ),
                _buildTextField(
                  'delaiLivraisonMoyen', 
                  'Délai de livraison (jours)', 
                  isNumeric: true,
                  minValue: 0,
                  icon: Icons.delivery_dining,
                ),
                _buildTextField('conditionsPaiement', 'Conditions de paiement', icon: Icons.payment),
                _buildTextField('notes', 'Notes', icon: Icons.note, maxLines: 3),
                
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.fournisseurId != null
          ? "Modifier ${widget.isEntreprise ? "Entreprise" : "Personne"}"
          : "Nouveau ${widget.isEntreprise ? "Entreprise" : "Personne"}",
      style: const TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildTextField(
    String fieldKey,
    String label, {
    bool isNumeric = false,
    bool isEmail = false,
    bool isPhone = false,
    IconData? icon,
    int maxLines = 1,
    int? minValue,
    int? maxValue,
  }) {
    return Padding(
      padding: 
       EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: _controllers[fieldKey],
        keyboardType: _getKeyboardType(isNumeric, isEmail),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => _validateField(
          value, 
          label, 
          isNumeric, 
          isEmail, 
          isPhone, 
          minValue, 
          maxValue,
        ),
      ),
    );
  }

  TextInputType _getKeyboardType(bool isNumeric, bool isEmail) {
    if (isNumeric) return TextInputType.number;
    if (isEmail) return TextInputType.emailAddress;
    if (isPhone) return TextInputType.phone;
    return TextInputType.text;
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: 
         EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              widget.fournisseurId != null ? 'Modifier' : 'Enregistrer',
              style: const TextStyle(fontSize: 16),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<FournisseurProvider>(context, listen: false);
      final fournisseur = _createFournisseurFromForm();

      bool success;
      if (widget.fournisseurId != null) {
        success = await provider.updateFournisseur(widget.fournisseurId!, fournisseur);
      } else {
        success = await provider.addFournisseur(fournisseur);
      }

      if (!context.mounted) return;

      if (success) {
        _handleSuccess();
      } else {
        _showErrorMessage(provider.error ?? 'Erreur lors de l\'opération');
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorMessage('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Fournisseur _createFournisseurFromForm() {
    return Fournisseur(
      id: widget.fournisseurId,
      type: widget.isEntreprise ? 'Entreprise' : 'Personne',
      nom: widget.isEntreprise ? null : _controllers['nom']!.text.trim(),
      prenom: widget.isEntreprise ? null : _controllers['prenom']!.text.trim(),
      entreprise: widget.isEntreprise ? _controllers['entreprise']!.text.trim() : null,
      matricule: widget.isEntreprise ? _controllers['matricule']!.text.trim() : null,
      email: _controllers['email']!.text.trim(),
      telephone: _controllers['telephone']!.text.trim(),
      adresse: _controllers['adresse']!.text.trim(),
      evaluation: int.tryParse(_controllers['evaluation']!.text) ?? 0,
      delaiLivraisonMoyen: int.tryParse(_controllers['delaiLivraisonMoyen']!.text) ?? 0,
      conditionsPaiement: _controllers['conditionsPaiement']!.text.trim(),
      notes: _controllers['notes']!.text.trim(),
      dateCreation: widget.fournisseurData['dateCreation'] != null
          ? DateTime.parse(widget.fournisseurData['dateCreation'])
          : DateTime.now(),
    );
  }

  void _handleSuccess() {
    final message = widget.fournisseurId != null 
        ? 'Fournisseur modifié avec succès' 
        : 'Fournisseur créé avec succès';
    
    _showSuccessMessage(message);
    
    if (widget.fournisseurId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FournisseurList()),
      );
    } else {
      _resetForm();
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      for (var controller in _controllers.values) {
        if (controller == _controllers['evaluation']) {
          controller.text = '0';
        } else if (controller == _controllers['delaiLivraisonMoyen']) {
          controller.text = '0';
        } else {
          controller.clear();
        }
      }
    });
  }

  String? _validateField(
    String? value, 
    String label, 
    bool isNumeric, 
    bool isEmail,
    bool isPhone,
    int? minValue,
    int? maxValue,
  ) {
    if (value == null || value.isEmpty) {
      if (label != 'Notes' && !(label == 'Prénom' && widget.isEntreprise)) {
        return 'Ce champ est obligatoire';
      }
      return null;
    }

    if (isEmail && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Email invalide';
    }

    if (isPhone && !RegExp(r'^[0-9]{8}$').hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }

    if (isNumeric) {
      final num = int.tryParse(value);
      if (num == null) return 'Veuillez entrer un nombre valide';
      
      if (minValue != null && num < minValue) {
        return 'La valeur doit être ≥ $minValue';
      }
      
      if (maxValue != null && num > maxValue) {
        return 'La valeur doit être ≤ $maxValue';
      }
    }

    return null;
  }
}