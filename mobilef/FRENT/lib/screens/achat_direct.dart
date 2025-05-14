import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';

class DirectPurchaseScreen extends StatefulWidget {
  const DirectPurchaseScreen({super.key});

  @override
  _DirectPurchaseScreenState createState() => _DirectPurchaseScreenState();
}

class _DirectPurchaseScreenState extends State<DirectPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final PurchaseService _purchaseService = PurchaseService();
  String? _articleId;
  String? _supplierId;
  double _tva = 20.0;
  double _prixTTC = 0.0;

  final TextEditingController _prixHTController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController(text: '1');
  final TextEditingController _tvaController = TextEditingController(text: '20');

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achat Direct',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouvel Achat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, String>>>(
                      future: _purchaseService.getArticles(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur de chargement des articles');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucun article disponible');
                        }
                        return DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Article'),
                          items: snapshot.data!
                              .map((article) => DropdownMenuItem(
                                    value: article['id'],
                                    child: Text(article['name']!),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _articleId = value),
                          validator: (value) => value == null ? 'Veuillez sélectionner un article' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, String>>>(
                      future: _purchaseService.getSuppliers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Erreur de chargement des fournisseurs');
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Aucun fournisseur disponible');
                        }
                        return DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Fournisseur'),
                          items: snapshot.data!
                              .map((supplier) => DropdownMenuItem(
                                    value: supplier['id'],
                                    child: Text(supplier['name']!),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _supplierId = value),
                          validator: (value) => value == null ? 'Veuillez sélectionner un fournisseur' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _prixHTController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: _inputDecoration('Prix HT (€)'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (double.tryParse(value!) == null) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tvaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: _inputDecoration('TVA (%)'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (double.tryParse(value!) == null) return 'Valeur invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantiteController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: _inputDecoration('Quantité'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Ce champ est requis';
                        if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                          return 'Quantité doit être un nombre positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      decoration: _inputDecoration('Prix TTC (€)').copyWith(
                        prefixIcon: const Icon(Icons.euro, color: Colors.grey),
                      ),
                      controller: TextEditingController(text: _prixTTC.toStringAsFixed(2)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _prixHTController.clear();
                            _tvaController.text = '20';
                            _quantiteController.text = '1';
                            setState(() {
                              _articleId = null;
                              _supplierId = null;
                              _prixTTC = 0.0;
                            });
                            _formKey.currentState?.reset();
                          },
                          child: const Text('Réinitialiser'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final purchase = Purchase(
                                articleId: _articleId!,
                                supplierId: _supplierId!,
                                prixHT: double.parse(_prixHTController.text),
                                tva: double.parse(_tvaController.text),
                                quantite: int.parse(_quantiteController.text),
                                prixTTC: _prixTTC,
                                date: DateTime.now(),
                              );
                              bool success = await _purchaseService.savePurchase(purchase);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Achat enregistré avec succès'
                                        : 'Erreur lors de l\'enregistrement',
                                  ),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              if (success) {
                                _formKey.currentState?.reset();
                                _prixHTController.clear();
                                _tvaController.text = '20';
                                _quantiteController.text = '1';
                                setState(() {
                                  _articleId = null;
                                  _supplierId = null;
                                  _prixTTC = 0.0;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Enregistrer l\'achat',
                            style: TextStyle(fontSize: 16),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  void dispose() {
    _prixHTController.dispose();
    _tvaController.dispose();
    _quantiteController.dispose();
    super.dispose();
  }
}
