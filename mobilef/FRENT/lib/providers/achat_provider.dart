import 'package:flutter/material.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService service;
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _error;
  List<Map<String, String>> _suppliers = [];
  List<Map<String, String>> _articles = [];

  PurchaseProvider({required this.service});

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, String>> get suppliers => _suppliers;
  List<Map<String, String>> get articles => _articles;

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchPurchases(),
      fetchSuppliers(),
      fetchArticles(),
    ]);
  }

  Future<void> fetchPurchases() async {
    _setLoading(true);
    try {
      _purchases = await service.fetchPurchases();
      _error = null;
    } catch (e) {
      _error = 'Échec du chargement des achats: ${e.toString()}';
      _purchases = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSuppliers() async {
    try {
      _suppliers = await service.getfetchSuppliers();
      _error = null;
    } catch (e) {
      _error = 'Échec du chargement des fournisseurs: ${e.toString()}';
      _suppliers = [];
    }
    notifyListeners();
  }

  Future<void> fetchArticles() async {
    try {
      _articles = await service.getArticles();
      _error = null;
    } catch (e) {
      _error = 'Échec du chargement des articles: ${e.toString()}';
      _articles = [];
    }
    notifyListeners();
  }

  Future<bool> savePurchase(Purchase purchase) async {
    _setLoading(true);
    try {
      final success = await service.savePurchase(purchase);
      if (success) {
        await fetchPurchases();
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Échec de l\'enregistrement de l\'achat: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePurchase(String id) async {
    _setLoading(true);
    try {
      final success = await service.deletePurchase(id);
      if (success) {
        await fetchPurchases();
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Échec de la suppression de l\'achat: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePurchase(Purchase purchase) async {
    _setLoading(true);
    try {
      final success = await service.updatePurchase(purchase);
      if (success) {
        await fetchPurchases();
      }
      _error = null;
      return success;
    } catch (e) {
      _error = 'Échec de la mise à jour de l\'achat: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
