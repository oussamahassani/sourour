import 'package:flutter/material.dart';
import '../models/fournisseur.dart';
import '../services/fournisseur_service.dart';

class FournisseurProvider with ChangeNotifier {
  FournisseurService _service;
  List<Fournisseur> _fournisseurs = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  FournisseurProvider({required FournisseurService service}) : _service = service;

  // Getter pour exposer les données
  List<Fournisseur> get fournisseurs => List.unmodifiable(_fournisseurs);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  // Setter pour mise à jour dynamique du service (utile avec ProxyProvider)
  set service(FournisseurService service) {
    _service = service;
    notifyListeners();
  }

  Future<void> loadFournisseurs({bool forceRefresh = false}) async {
    if (!forceRefresh && _hasLoaded && _error == null) return;

    _setLoading(true);
    try {
      final fetched = await _service.getFournisseurs();
      _fournisseurs = fetched;
      _hasLoaded = true;
      _clearError();
    } catch (e) {
      _setError(e.toString());
      _fournisseurs = [];
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addFournisseur(Fournisseur fournisseur) async {
    _setLoading(true);
    try {
      final newFournisseur = await _service.createFournisseur(fournisseur);
      _fournisseurs = [..._fournisseurs, newFournisseur];
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFournisseur(String id, Fournisseur fournisseur) async {
    _setLoading(true);
    try {
      final updated = await _service.updateFournisseur(id, fournisseur);
      _fournisseurs = _fournisseurs.map((f) => f.id == id ? updated : f).toList();
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFournisseur(String id) async {
    _setLoading(true);
    try {
      await _service.deleteFournisseur(id);
      _fournisseurs.removeWhere((f) => f.id == id);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Fournisseur>> searchFournisseurs(String query) async {
    _setLoading(true);
    try {
      final results = await _service.searchFournisseurs(query);
      _clearError();
      return results;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Fournisseur? getFournisseurById(String id) {
    try {
      return _fournisseurs.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Helpers privés

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  updateService(FournisseurService service) {
    
  }
}
