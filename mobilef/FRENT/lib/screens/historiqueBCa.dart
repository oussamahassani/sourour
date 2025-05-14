import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/achat.dart';
import '../services/achat_service.dart';
import 'achat_direct.dart';
import 'bonCommandeAchat.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  String _searchQuery = '';
  String _selectedType = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define a consistent theme for typography and colors
    final theme = Theme.of(context);
    const cardMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
    const contentPadding = EdgeInsets.all(16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historique des Achats',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 2, // Subtle shadow for depth
        backgroundColor: theme.primaryColor, // Use theme primary color
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Bar
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
                // Filter Dropdown
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
          // Purchase List
          Expanded(
            child: FutureBuilder<List<Purchase>>(
              future: _purchaseService.getPurchases(),
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
                final filteredPurchases = purchases.where((purchase) {
                  final articleName = _purchaseService.getArticleName(purchase.articleId);
                  final supplierName = _purchaseService.getSupplierName(purchase.supplierId);
                  final purchaseType = _purchaseService.getPurchaseType(purchase);
                  final matchesSearch = articleName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      supplierName.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesType = _selectedType == 'Tous' || purchaseType == _selectedType;
                  return matchesSearch && matchesType;
                }).toList();

                if (filteredPurchases.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun achat trouvé',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  itemCount: filteredPurchases.length,
                  itemBuilder: (context, index) {
                    final purchase = filteredPurchases[index];
                    final articleName = _purchaseService.getArticleName(purchase.articleId);
                    final supplierName = _purchaseService.getSupplierName(purchase.supplierId);
                    final purchaseType = _purchaseService.getPurchaseType(purchase);

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
                              Text('Type: $purchaseType', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${_purchaseService.formatDate(purchase.date)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Prix TTC: ${purchase.prixTTC.toStringAsFixed(2)} €',
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
                        onTap: () => _showPurchaseDetails(purchase), // Tap card to show details
                      ),
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
    final articleName = _purchaseService.getArticleName(purchase.articleId);
    final supplierName = _purchaseService.getSupplierName(purchase.supplierId);
    final purchaseType = _purchaseService.getPurchaseType(purchase);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _buildDetailRow('Type', purchaseType, theme),
              _buildDetailRow('Date', _purchaseService.formatDate(purchase.date), theme),
              _buildDetailRow('Prix HT', '${purchase.prixHT.toStringAsFixed(2)} €', theme),
              _buildDetailRow('TVA', '${purchase.tva.toStringAsFixed(2)} %', theme),
              _buildDetailRow('Quantité', '${purchase.quantite}', theme),
              _buildDetailRow('Prix TTC', '${purchase.prixTTC.toStringAsFixed(2)} €', theme),
              if (purchase.delaiLivraison != null)
                _buildDetailRow('Délai de livraison', '${purchase.delaiLivraison} jours', theme),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
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
              bool success = await _purchaseService.deletePurchase(purchase.id!);
              Navigator.pop(context);
              setState(() {}); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Achat supprimé avec succès' : 'Erreur lors de la suppression',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  backgroundColor: success ? theme.colorScheme.primary : theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              );
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
    final route = purchase.delaiLivraison != null
        ? MaterialPageRoute(builder: (context) => OrderedPurchaseScreen())
        : MaterialPageRoute(builder: (context) => DirectPurchaseScreen());
    Navigator.push(context, route).then((value) {
      setState(() {}); // Refresh the list after editing
    });
  }

  void _generatePdf(Purchase purchase) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDF généré pour ${_purchaseService.getArticleName(purchase.articleId)}',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }
}
