import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';
import 'achat_direct.dart';
import 'bonCommandeAchat.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  String _searchQuery = '';
  String _selectedType = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, String>>> _articlesFuture;
  late Future<List<Map<String, String>>> _suppliersFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _purchaseService.getArticles();
    _suppliersFuture = _purchaseService.getfetchSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _getArticleName(String id_article) async {
    try {
      final articles = await _articlesFuture;
      return articles.firstWhere(
        (article) => article['id'] == id_article,
        orElse: () => {'name': 'Article inconnu'},
      )['name']!;
    } catch (e) {
      return 'Article inconnu';
    }
  }

  Future<String> _getSupplierName(String id_fournisseur) async {
    try {
      final suppliers = await _suppliersFuture;
      return suppliers.firstWhere(
        (supplier) => supplier['id'] == id_fournisseur,
        orElse: () => {'name': 'Fournisseur inconnu'},
      )['name']!;
    } catch (e) {
      return 'Fournisseur inconnu';
    }
  }

  Future<List<Purchase>> _filterPurchases(List<Purchase> purchases) async {
    if (_searchQuery.isEmpty && _selectedType == 'Tous') {
      return purchases;
    }

    final filtered = <Purchase>[];
    for (final purchase in purchases) {
      // Filter by type first (synchronous)
      if (_selectedType != 'Tous' && purchase.type_achat != _selectedType) {
        continue;
      }

      // Filter by search query if needed
      if (_searchQuery.isNotEmpty) {
        final articleName = await _getArticleName(purchase.id_article);
        final supplierName = await _getSupplierName(purchase.id_fournisseur);
        if (!articleName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !supplierName.toLowerCase().contains(_searchQuery.toLowerCase())) {
          continue;
        }
      }

      filtered.add(purchase);
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cardMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    const contentPadding = EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des Achats',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un article ou fournisseur',
                      prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: ['Tous', 'Direct', 'Commandé'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 16)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Purchase>>(
              future: _purchaseService.fetchPurchases(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur lors du chargement des achats',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                  );
                }
                final purchases = snapshot.data ?? [];
                if (purchases.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun achat trouvé',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  );
                }

                return FutureBuilder<List<Purchase>>(
                  future: _filterPurchases(purchases),
                  builder: (context, filteredSnapshot) {
                    if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filteredSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erreur lors du filtrage',
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                        ),
                      );
                    }
                    final filteredPurchases = filteredSnapshot.data ?? [];
                    if (filteredPurchases.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun achat correspondant',
                          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        return FutureBuilder<List<String>>(
                          future: Future.wait([
                            _getArticleName(purchase.id_article),
                            _getSupplierName(purchase.id_fournisseur),
                          ]),
                          builder: (context, nameSnapshot) {
                            if (nameSnapshot.connectionState == ConnectionState.waiting) {
                              return const Card(
                                margin: cardMargin,
                                child: ListTile(
                                  title: SizedBox(
                                    height: 24,
                                    child: LinearProgressIndicator(),
                                  ),
                                ),
                              );
                            }
                            final articleName = nameSnapshot.data?[0] ?? 'Article inconnu';
                            final supplierName = nameSnapshot.data?[1] ?? 'Fournisseur inconnu';

                            return Card(
                              margin: cardMargin,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              child: ListTile(
                                contentPadding: contentPadding,
                                title: Text(
                                  articleName,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fournisseur: $supplierName', style: theme.textTheme.bodyMedium),
                                      const SizedBox(height: 4),
                                      Text('Type: ${purchase.type_achat}', style: theme.textTheme.bodyMedium),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Date: ${DateFormat('yyyy-MM-dd').format(purchase.date_achat)}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Prix TTC: ${purchase.prix_achatTTC.toStringAsFixed(2)} €',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'details', child: Text('Détails')),
                                    const PopupMenuItem(value: 'modify', child: Text('Modifier')),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Supprimer',
                                        style: TextStyle(color: theme.colorScheme.error),
                                      ),
                                    ),
                                    const PopupMenuItem(value: 'pdf', child: Text('Générer PDF')),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'details':
                                        _showPurchaseDetails(purchase);
                                        break;
                                      case 'modify':
                                        _navigateToEditScreen(purchase);
                                        break;
                                      case 'delete':
                                        _confirmDelete(purchase);
                                        break;
                                      case 'pdf':
                                        _generatePdf(purchase);
                                        break;
                                    }
                                  },
                                ),
                                onTap: () => _showPurchaseDetails(purchase),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDetails(Purchase purchase) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<String>>(
        future: Future.wait([
          _getArticleName(purchase.id_article),
          _getSupplierName(purchase.id_fournisseur),
        ]),
        builder: (context, snapshot) {
          final articleName = snapshot.data?[0] ?? 'Article inconnu';
          final supplierName = snapshot.data?[1] ?? 'Fournisseur inconnu';

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            title: Text(
              'Détails de l\'achat',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Article', articleName, theme),
                  _buildDetailRow('Fournisseur', supplierName, theme),
                  _buildDetailRow('Type', purchase.type_achat, theme),
                  _buildDetailRow('Date', DateFormat('yyyy-MM-dd').format(purchase.date_achat), theme),
                  _buildDetailRow('Prix HT', '${purchase.prix_achatHT.toStringAsFixed(2)} €', theme),
                  _buildDetailRow('TVA', '${purchase.TVA.toStringAsFixed(2)} %', theme),
                  _buildDetailRow('Quantité', '${purchase.quantite}', theme),
                  _buildDetailRow('Prix TTC', '${purchase.prix_achatTTC.toStringAsFixed(2)} €', theme),
                  if (purchase.delai_livraison != null)
                    _buildDetailRow('Délai de livraison', '${purchase.delai_livraison} jours', theme),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer', style: TextStyle(color: theme.colorScheme.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Purchase purchase) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(
          'Confirmer la suppression',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        content: const Text('Voulez-vous vraiment supprimer cet achat ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: theme.colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () async {
              if (purchase.id != null) {
                bool success = await _purchaseService.deletePurchase(purchase.id!);
                Navigator.pop(context);
                if (success) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Achat supprimé avec succès'),
                      backgroundColor: theme.colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Erreur lors de la suppression'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Supprimer',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(Purchase purchase) {
    final route = purchase.type_achat == 'Commandé'
        ? MaterialPageRoute(builder: (context) => OrderedPurchaseScreen(purchase: purchase))
        : MaterialPageRoute(builder: (context) => DirectPurchaseScreen(purchase: purchase));
    Navigator.push(context, route).then((value) {
      setState(() {});
    });
  }

  void _generatePdf(Purchase purchase) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité PDF non implémentée'),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
