import 'package:intl/intl.dart';

import '../models/achat.dart'; // For date formatting
class PurchaseService {
  // Mock database (replace with actual database like Firestore or SQLite)
  final List<Purchase> _purchases = [
    Purchase(
      id: '1',
      articleId: '1',
      supplierId: '1',
      prixHT: 100.0,
      tva: 20.0,
      quantite: 1,
      prixTTC: 120.0,
      date: DateTime(2023, 5, 10),
    ),
    Purchase(
      id: '2',
      articleId: '2',
      supplierId: '2',
      prixHT: 74.99,
      tva: 20.0,
      quantite: 1,
      prixTTC: 89.99,
      delaiLivraison: 7,
      date: DateTime(2023, 5, 12),
    ),
  ];

  // Mock article and supplier data
  final Map<String, String> _articles = {
    '1': 'Article 1',
    '2': 'Article 2',
  };
  final Map<String, String> _suppliers = {
    '1': 'Fournisseur A',
    '2': 'Fournisseur B',
  };

  // Save a purchase
  Future<bool> savePurchase(Purchase purchase) async {
    try {
      _purchases.add(purchase);
      print('Purchase saved: ${purchase.toJson()}');
      return true;
    } catch (e) {
      print('Error saving purchase: $e');
      return false;
    }
  }

  // Fetch all purchases
  Future<List<Purchase>> getPurchases() async {
    // Simulate database fetch
    return _purchases;
  }

  // Delete a purchase
  Future<bool> deletePurchase(String id) async {
    try {
      _purchases.removeWhere((purchase) => purchase.id == id);
      return true;
    } catch (e) {
      print('Error deleting purchase: $e');
      return false;
    }
  }

  // Update a purchase (for modify action)
  Future<bool> updatePurchase(Purchase updatedPurchase) async {
    try {
      int index = _purchases.indexWhere((p) => p.id == updatedPurchase.id);
      if (index != -1) {
        _purchases[index] = updatedPurchase;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating purchase: $e');
      return false;
    }
  }

  // Fetch articles
  Future<List<Map<String, String>>> getArticles() async {
    return _articles.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // Fetch suppliers
  Future<List<Map<String, String>>> getSuppliers() async {
    return _suppliers.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // Resolve article name
  String getArticleName(String articleId) {
    return _articles[articleId] ?? 'Unknown Article';
  }

  // Resolve supplier name
  String getSupplierName(String supplierId) {
    return _suppliers[supplierId] ?? 'Unknown Supplier';
  }

  // Get purchase type (Direct or Commandé)
  String getPurchaseType(Purchase purchase) {
    return purchase.delaiLivraison != null ? 'Commandé' : 'Direct';
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
