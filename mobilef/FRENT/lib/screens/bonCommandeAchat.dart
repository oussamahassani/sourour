import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';

class OrderedPurchaseScreen extends StatefulWidget {
  final Purchase? purchase;
  const OrderedPurchaseScreen({super.key, this.purchase});

  @override
  _OrderedPurchaseScreenState createState() => _OrderedPurchaseScreenState();
}

class _OrderedPurchaseScreenState extends State<OrderedPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final PurchaseService _purchaseService = PurchaseService();
  String? _id_article;
  String? _id_fournisseur;
  double _TVA = 20.0;
  double _prix_achatTTC = 0.0;
  int _delai_livraison = 7;

  final TextEditingController _prix_achatHTController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController(text: '1');
  final TextEditingController _TVAController = TextEditingController(text: '20');
  final TextEditingController _delaiController = TextEditingController(text: '7');

  late Future<List<Map<String, String>>> _suppliersFuture;
  late Future<List<Map<String, String>>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _prix_achatHTController.addListener(_calculateTTC);
    _TVAController.addListener(_calculateTTC);
    _quantiteController.addListener(_calculateTTC);
    _delaiController.addListener(() {
      setState(() {
        _delai_livraison = int.tryParse(_delaiController.text) ?? 7;
      });
    });

    if (widget.purchase != null) {
      _id_article = widget.purchase!.id_article;
      _id_fournisseur = widget.purchase!.id_fournisseur;
      _prix_achatHTController.text = widget.purchase!.prix_achatHT.toString();
      _TVAController.text = widget.purchase!.TVA.toString();
      _quantiteController.text = widget.purchase!.quantite.toString();
      _delaiController.text = widget.purchase!.delai_livraison?.toString() ?? '7';
      _TVA = widget.purchase!.TVA;
      _prix_achatTTC = widget.purchase!.prix_achatTTC;
      _delai_livraison = widget.purchase!.delai_livraison ?? 7;
    }
  }

  void _refreshData() {
    setState(() {
      _suppliersFuture = _purchaseService.getfetchSuppliers();
      _articlesFuture = _purchaseService.getArticles();
    });
  }

  void _calculateTTC() {
    if (_prix_achatHTController.text.isNotEmpty && _TVAController.text.isNotEmpty) {
      double prixHT = double.tryParse(_prix_achatHTController.text) ?? 0;
      double tva = double.tryParse(_TVAController.text) ?? 0;
      int quantite = int.tryParse(_quantiteController.text) ?? 1;

      setState(() {
        _TVA = tva;
        _prix_achatTTC = Purchase.calculateTTC(prixHT, tva, quantite);
      });
    }
  }

  void _resetForm() {
    _prix_achatHTController.clear();
    _TVAController.text = '20';
    _quantiteController.text = '1';
    _delaiController.text = '7';
    setState(() {
      _id_article = null;
      _id_fournisseur = null;
      _prix_achatTTC = 0.0;
      _delai_livraison = 7;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.purchase != null ? 'Modifier Bon de Commande' : 'Nouveau Bon de Commande',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Rafraîchir les données',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.purchase != null ? 'Modifier Bon de Commande' : 'Nouveau Bon de Commande',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      label: 'Article',
                      future: _articlesFuture,
                      value: _id_article,
                      onChanged: (value) => setState(() => _id_article = value),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Fournisseur',
                      future: _suppliersFuture,
                      value: _id_fournisseur,
                      onChanged: (value) => setState(() => _id_fournisseur = value),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _prix_achatHTController,
                      label: 'Prix HT (€)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (double.tryParse(value!) == null) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _TVAController,
                      label: 'TVA (%)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (double.tryParse(value!) == null) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _quantiteController,
                      label: 'Quantité',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                          return 'Quantité doit être un nombre positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: TextEditingController(text: _prix_achatTTC.toStringAsFixed(2)),
                      label: 'Prix TTC (€)',
                      readOnly: true,
                      prefixIcon: const Icon(Icons.euro, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _delaiController,
                      label: 'Délai de livraison (jours)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                          return 'Délai doit être un nombre positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _resetForm,
                          child: const Text('Réinitialiser'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final purchase = Purchase(
                                id: widget.purchase?.id,
                                id_article: _id_article!,
                                id_fournisseur: _id_fournisseur!,
                                prix_achatHT: double.parse(_prix_achatHTController.text),
                                TVA: double.parse(_TVAController.text),
                                quantite: int.parse(_quantiteController.text),
                                prix_achatTTC: _prix_achatTTC,
                                delai_livraison: _delai_livraison,
                                type_achat: 'Commandé',
                                date_achat: DateTime.now(),
                              );
                              bool success = widget.purchase != null
                                  ? await _purchaseService.updatePurchase(purchase)
                                  : await _purchaseService.savePurchase(purchase);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? widget.purchase != null
                                            ? 'Bon de commande modifié avec succès'
                                            : 'Bon de commande enregistré avec succès'
                                        : 'Erreur lors de l\'enregistrement',
                                  ),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              if (success) {
                                _resetForm();
                                if (widget.purchase != null) Navigator.pop(context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            widget.purchase != null ? 'Modifier la commande' : 'Enregistrer la commande',
                            style: const TextStyle(fontSize: 16),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    Icon? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: prefixIcon,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Future<List<Map<String, String>>> future,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder<List<Map<String, String>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Erreur de chargement des $label: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aucun $label disponible',
                  style: const TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: _refreshData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        bool isValidValue = value == null || data.any((item) => item['id'] == value);

        return DropdownButtonFormField<String>(
          value: isValidValue ? value : null,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Sélectionner un $label'),
            ),
            ...data.map((item) => DropdownMenuItem<String>(
                  value: item['id'],
                  child: Text(item['name'] ?? 'Sans nom'),
                )),
          ],
          onChanged: onChanged,
          validator: (value) => value == null ? 'Veuillez sélectionner un $label' : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _prix_achatHTController.dispose();
    _TVAController.dispose();
    _quantiteController.dispose();
    _delaiController.dispose();
    super.dispose();
  }
}
