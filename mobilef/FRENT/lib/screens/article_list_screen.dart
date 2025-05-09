import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/article_provider.dart';
import 'article.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({Key? key}) : super(key: key);

  @override
  _ArticleListScreenState createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      await provider.loadArticles();

      if (provider.articles.isEmpty) {
        setState(() {
          _errorMessage = 'Aucun article disponible';
        });
      }
    } catch (e) {
      debugPrint('Erreur de chargement: $e');
      setState(() {
        _errorMessage =
            'Erreur lors du chargement des articles: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  List<Article> _getFilteredArticles(List<Article> articles) {
    return articles.where((article) {
      final searchMatch =
          _searchController.text.isEmpty ||
          article.nomArticle.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          article.reference.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final categoryMatch =
          _selectedCategory == null ||
          _selectedCategory == 'Tous' ||
          article.categorie == _selectedCategory;

      return searchMatch && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final articles = articleProvider.articles;
    final filteredArticles = _getFilteredArticles(articles);

    final categories = ['Tous']..addAll(
      articles.map((a) => a.categorie ?? 'Non catégorisé').toSet().toList()
        ..removeWhere((c) => c == null),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ArticleFormScreen(
                          article:
                              null, // Pass an existing article if editing, or null for new
                          onSave: (newArticle) async {},
                        ),
                  ),
                ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadArticles),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(category),
                              selected:
                                  _selectedCategory == category ||
                                  (category == 'Tous' &&
                                      _selectedCategory == null),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected
                                          ? (category == 'Tous'
                                              ? null
                                              : category)
                                          : null;
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadArticles,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredArticles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 50, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty &&
                              _selectedCategory == null
                          ? 'Aucun article disponible'
                          : 'Aucun article correspondant aux critères',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadArticles,
                child: ListView.builder(
                  itemCount: filteredArticles.length,
                  itemBuilder: (context, index) {
                    final article = filteredArticles[index];
                    return _buildArticleItem(context, article);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, Article article) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              article.image?.isNotEmpty == true
                  ? Image.network(article.image!, fit: BoxFit.cover)
                  : const Icon(Icons.inventory, color: Colors.grey),
        ),
        title: Text(article.nomArticle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Réf: ${article.reference}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${article.prixVente?.toStringAsFixed(2) ?? '0.00'} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (article.stock ?? 0) <= (article.seuilAlerte ?? 0)
                            ? Colors.red[50]
                            : Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (article.stock ?? 0) <= (article.seuilAlerte ?? 0)
                        ? 'Stock bas (${article.stock})'
                        : 'En stock (${article.stock})',
                    style: TextStyle(
                      color:
                          (article.stock ?? 0) <= (article.seuilAlerte ?? 0)
                              ? Colors.red
                              : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showArticleDetails(context, article),
      ),
    );
  }

  void _showArticleDetails(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ArticleDetailBottomSheet(article: article),
    );
  }
}

class ArticleDetailBottomSheet extends StatelessWidget {
  final Article article;

  const ArticleDetailBottomSheet({Key? key, required this.article})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      article.image?.isNotEmpty == true
                          ? Image.network(article.image!, fit: BoxFit.cover)
                          : const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.nomArticle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Réf: ${article.reference}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (article.stock ?? 0) <= (article.seuilAlerte ?? 0)
                                  ? Colors.red[50]
                                  : Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (article.stock ?? 0) <= (article.seuilAlerte ?? 0)
                              ? 'Stock bas: ${article.stock}'
                              : 'En stock: ${article.stock}',
                          style: TextStyle(
                            color:
                                (article.stock ?? 0) <=
                                        (article.seuilAlerte ?? 0)
                                    ? Colors.red
                                    : Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            _buildDetailRow('Catégorie', article.categorie ?? 'Non spécifiée'),
            _buildDetailRow('Type', article.type ?? 'Non spécifié'),
            _buildDetailRow(
              'Prix d\'achat',
              '${article.prixAchat?.toStringAsFixed(2) ?? '0.00'} €',
            ),
            _buildDetailRow(
              'Prix de vente',
              '${article.prixVente?.toStringAsFixed(2) ?? '0.00'} €',
            ),
            _buildDetailRow(
              'Marge',
              '${article.tauxMarge?.toStringAsFixed(2) ?? '0.00'}%',
            ),
            _buildDetailRow(
              'Seuil d\'alerte',
              article.seuilAlerte?.toString() ?? '0',
            ),
            _buildDetailRow(
              'Date d\'ajout',
              article.dateAjout != null
                  ? DateFormat('dd/MM/yyyy').format(article.dateAjout!)
                  : 'Date inconnue',
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              article.description?.isNotEmpty == true
                  ? article.description!
                  : 'Aucune description disponible',
              style: TextStyle(
                color:
                    article.description?.isNotEmpty == true
                        ? null
                        : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ArticleFormScreen(
                                article:
                                    article, // Pass an existing article if editing, or null for new
                                onSave: (newArticle) async {},
                              ),
                        ),
                      );
                    },
                    child: const Text('MODIFIER'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(context),
                    child: const Text(
                      'SUPPRIMER',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text('Voulez-vous vraiment supprimer cet article ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ANNULER'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final provider = Provider.of<ArticleProvider>(
                      context,
                      listen: false,
                    );
                    await provider.deleteArticle(article.id!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Article supprimé avec succès'),
                      ),
                    );
                    // Rafraîchir la liste après suppression
                    provider.loadArticles();
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                },
                child: const Text(
                  'SUPPRIMER',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
