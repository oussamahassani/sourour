// lib/providers/paiement_provider.dart
import 'package:flutter/material.dart';
import '../models/paiement.dart';
import '../services/paiement_service.dart';

class PaiementProvider with ChangeNotifier {
  List<Paiement> _paiements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Paiement> get paiements => _paiements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final PaiementService _paiementService = PaiementService();

  Future<void> fetchPaiements() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paiements = await _paiementService.fetchPaiements();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPaiement(Paiement paiement) async {
    try {
      final newPaiement = await _paiementService.createPaiement(paiement);
      _paiements.add(newPaiement);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePaiement(String id, Paiement paiement) async {
    try {
      final updatedPaiement = await _paiementService.updatePaiement(id, paiement);
      final index = _paiements.indexWhere((p) => p.id == id);
      if (index != -1) {
        _paiements[index] = updatedPaiement;
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePaiement(String id) async {
    try {
      await _paiementService.deletePaiement(id);
      _paiements.removeWhere((p) => p.id == id);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
