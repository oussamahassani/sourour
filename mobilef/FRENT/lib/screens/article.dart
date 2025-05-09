import 'package:flutter/material.dart';

import '../models/article.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import 'article_list_screen.dart';

class ArticleFormScreen extends StatefulWidget {
  final Article? article;

  const ArticleFormScreen({
    Key? key,
    this.article,
    required Future<dynamic> Function(dynamic Article) onSave,
  }) : super(key: key);
  @override
  _ArticleFormScreenState createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _referenceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prixAchatController;
  late final TextEditingController _prixVenteController;
  late final TextEditingController _margeController;
  late final TextEditingController _seuilAlerteController;

  String? _categorie;
  String? _type;
  String? _imageUrl;
  bool _isCalculatingFromMargin = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Climatiseur',
    'Chauffage',
    'Réfrigération',
    'Plomberie',
    'Sanitaire',
    'Électricité',
    'Ventilation',
  ];

  final List<String> _types = ['article achat', 'article vente', 'autre'];

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _referenceController = TextEditingController();
    _descriptionController = TextEditingController();
    _prixAchatController = TextEditingController();
    _prixVenteController = TextEditingController();
    _margeController = TextEditingController();
    _seuilAlerteController = TextEditingController();

    _initializeForm();
  }

  void _initializeForm() {
    if (widget.article != null) {
      final article = widget.article!;
      _nomController.text = article.nomArticle;
      _referenceController.text = article.reference;
      _descriptionController.text = article.description ?? '';
      _prixAchatController.text =
          article.prixAchat?.toStringAsFixed(2) ?? '0.00';
      _prixVenteController.text =
          article.prixVente?.toStringAsFixed(2) ?? '0.00';
      _margeController.text = (article.tauxMarge ?? 0).toStringAsFixed(2);
      _seuilAlerteController.text = (article.seuilAlerte ?? 0).toString();
      _categorie = article.categorie ?? _categories.first;
      _type = article.type ?? _types.first;
      _imageUrl = article.image;
    } else {
      _seuilAlerteController.text = '0';
      _margeController.text = '0';
      _categorie = _categories.first;
      _type = _types.first;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _prixAchatController.dispose();
    _prixVenteController.dispose();
    _margeController.dispose();
    _seuilAlerteController.dispose();
    super.dispose();
  }

  void _calculateFromMargin() {
    if (_prixAchatController.text.isEmpty || _margeController.text.isEmpty)
      return;

    final prixAchat =
        double.tryParse(_prixAchatController.text.replaceAll(',', '.')) ?? 0;
    final marge =
        double.tryParse(_margeController.text.replaceAll(',', '.')) ?? 0;

    if (prixAchat == 0) return;

    final prixVente = prixAchat * (1 + marge / 100);
    _prixVenteController.text = prixVente.toStringAsFixed(2);
  }

  void _calculateFromSalePrice() {
    if (_prixAchatController.text.isEmpty || _prixVenteController.text.isEmpty)
      return;

    final prixAchat =
        double.tryParse(_prixAchatController.text.replaceAll(',', '.')) ?? 0;
    final prixVente =
        double.tryParse(_prixVenteController.text.replaceAll(',', '.')) ?? 0;

    if (prixAchat == 0) return;

    final marge = ((prixVente - prixAchat) / prixAchat) * 100;
    _margeController.text = marge.toStringAsFixed(2);
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    String ids;
    if (widget.article != null) {
      ids = widget.article!.id;
    } else {
      ids = timestamp.toString();
    }
    // try {
    final article = Article(
      id: ids,
      nomArticle: _nomController.text.trim(),
      reference: _referenceController.text.trim(),
      categorie: _categorie,
      type: _type,
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      prixAchat: double.parse(_prixAchatController.text.replaceAll(',', '.')),
      prixVente: double.parse(_prixVenteController.text.replaceAll(',', '.')),
      tauxMarge: double.parse(_margeController.text.replaceAll(',', '.')),
      stock: widget.article?.stock ?? 0,
      seuilAlerte: int.tryParse(_seuilAlerteController.text) ?? 0,
      dateAjout: widget.article?.dateAjout ?? DateTime.now(),
      image: "null",
    );

    final articleProvider = Provider.of<ArticleProvider>(
      context,
      listen: false,
    );
    print(widget);
    if (widget.article == null) {
      await articleProvider.addArticle(article);
    } else {
      await articleProvider.updateArticle(article);
    }

    if (!mounted) return;
    Navigator.pop(context);
    //  } catch (e) {
    //   print(e);
    /*  if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _saveArticle,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article == null ? 'Nouvel article' : 'Modifier article',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Voir la liste',
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticleListScreen(),
                  ),
                ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildFormFields(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child:
            _imageUrl != null && _imageUrl!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                )
                : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text('Ajouter une image', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _pickImage() async {
    // TODO: Implement with image_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'image à implémenter'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          _nomController,
          'Nom de l\'article *',
          validator: _validateRequired,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _referenceController,
          'Référence *',
          validator: _validateRequired,
        ),
        const SizedBox(height: 16),
        _buildDropdown(_categories, _categorie, 'Catégorie *', (value) {
          setState(() => _categorie = value);
        }),
        const SizedBox(height: 16),
        _buildDropdown(_types, _type, 'Type *', (value) {
          setState(() => _type = value);
        }),
        const SizedBox(height: 16),
        _buildTextField(_descriptionController, 'Description', maxLines: 3),
        const SizedBox(height: 16),
        _buildPriceFields(),
        const SizedBox(height: 16),
        _buildTextField(
          _seuilAlerteController,
          'Seuil d\'alerte',
          keyboardType: TextInputType.number,
          validator: _validateNumeric,
        ),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Column(
      children: [
        _buildTextField(
          _prixAchatController,
          'Prix d\'achat *',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: _validatePrice,
          onChanged:
              (_) =>
                  _isCalculatingFromMargin
                      ? _calculateFromMargin()
                      : _calculateFromSalePrice(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _prixVenteController,
                'Prix de vente *',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validatePrice,
                onChanged: (_) {
                  setState(() => _isCalculatingFromMargin = false);
                  _calculateFromSalePrice();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                _margeController,
                'Marge (%) *',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                suffixText: '%',
                validator: _validatePrice,
                onChanged: (_) {
                  setState(() => _isCalculatingFromMargin = true);
                  _calculateFromMargin();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveArticle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      widget.article == null ? 'Enregistrer' : 'Mettre à jour',
                      style: const TextStyle(color: Colors.white),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? suffixText,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffixText,
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? value,
    String label,
    void Function(String?)? onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            onChanged?.call(newValue);
          });
        }
      },
      validator: (value) => value == null ? 'Ce champ est obligatoire' : null,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obligatoire';
    }
    final numericValue = double.tryParse(value.replaceAll(',', '.'));
    if (numericValue == null) {
      return 'Nombre invalide';
    }
    if (numericValue <= 0) {
      return 'Doit être > 0';
    }
    return null;
  }

  String? _validateNumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final numericValue = int.tryParse(value);
    if (numericValue == null) {
      return 'Nombre entier requis';
    }
    if (numericValue < 0) {
      return 'Doit être ≥ 0';
    }
    return null;
  }
}
