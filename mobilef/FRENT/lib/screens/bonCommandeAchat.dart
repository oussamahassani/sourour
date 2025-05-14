import 'package:flutter/material.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';

class OrderedPurchaseScreen extends StatefulWidget {
  const OrderedPurchaseScreen({Key? key}) : super(key: key);
  
  @override
  _OrderedPurchaseScreenState createState() => _OrderedPurchaseScreenState();
}

class _OrderedPurchaseScreenState extends State<OrderedPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final PurchaseService _purchaseService = PurchaseService();
  String? _articleId;
  String? _supplierId;
  double _tva = 20.0;
  double _prixTTC = 0.0;
  int _delaiLivraison = 7;

  final TextEditingController _prixHTController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController(text: '1');
  final TextEditingController _tvaController = TextEditingController(text: '20');
  final TextEditingController _delaiController = TextEditingController(text: '7');

  @override
  void initState() {
    super.initState();
    _prixHTController.addListener(_calculateTTC);
    _tvaController.addListener(_calculateTTC);
    _quantiteController.addListener(_calculateTTC);
  }

  void _calculateTTC() {
    if (_prixHTController.text.isNotEmpty && _tvaController.text.isNotEmpty) {
      double prixHT = double.tryParse(_prixHTController.text) ?? 0;
      double tva = double.tryParse(_tvaController.text) ?? 0;
      int quantite = int.tryParse(_quantiteController.text) ?? 1;

      setState(() {
        _tva = tva;
        _prixTTC = Purchase.calculateTTC(prixHT, tva, quantite);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouvelle Commande',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de la Commande',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDropdownField(
                      context: context,
                      label: 'Article',
                      future: _purchaseService.getArticles(),
                      onChanged: (value) => setState(() => _articleId = value),
                      validator: (value) => value == null ? 'Veuillez sélectionner un article' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      context: context,
                      label: 'Fournisseur',
                      future: _purchaseService.getSuppliers(),
                      onChanged: (value) => setState(() => _supplierId = value),
                      validator: (value) => value == null ? 'Veuillez sélectionner un fournisseur' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _prixHTController,
                      label: 'Prix HT (€)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tvaController,
                      label: 'TVA (%)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _quantiteController,
                      label: 'Quantité',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: TextEditingController(text: _prixTTC.toStringAsFixed(2)),
                      label: 'Prix TTC (€)',
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _delaiController,
                      label: 'Délai de livraison (jours)',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                      onChanged: (value) {
                        setState(() {
                          _delaiLivraison = int.tryParse(value) ?? 7;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final purchase = Purchase(
                              articleId: _articleId!,
                              supplierId: _supplierId!,
                              prixHT: double.parse(_prixHTController.text),
                              tva: double.parse(_tvaController.text),
                              quantite: int.parse(_quantiteController.text),
                              prixTTC: _prixTTC,
                              delaiLivraison: _delaiLivraison,
                              date: DateTime.now(),
                            );
                            bool success = await _purchaseService.savePurchase(purchase);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Commande enregistrée avec succès'
                                      : 'Erreur lors de l\'enregistrement',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer la Commande',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
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
    String? Function(String?)? validator,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required Future<List<Map<String, String>>> future,
    required ValueChanged<String?> onChanged,
    required String? Function(String?) validator,
  }) {
    return FutureBuilder<List<Map<String, String>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: snapshot.data!
              .map((item) => DropdownMenuItem(
                    value: item['id'],
                    child: Text(item['name']!),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        );
      },
    );
  }

  @override
  void dispose() {
    _prixHTController.dispose();
    _tvaController.dispose();
    _quantiteController.dispose();
    _delaiController.dispose();
    super.dispose();
  }
}
