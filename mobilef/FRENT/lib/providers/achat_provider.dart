import 'package:flutter/material.dart';
import '../models/achat.dart';
import '../services/achat_service.dart';

class AchatDirectProvider with ChangeNotifier {
  final AchatDirectService _achatDirectService = AchatDirectService();
  List<AchatDirect> _achatsDirects = [];
  bool _isLoading = false;
  String? _error;

  List<AchatDirect> get achatsDirects => _achatsDirects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAchatsDirects() async {
    _isLoading = true;
    notifyListeners();

    try {
      _achatsDirects = await _achatDirectService.fetchAchatsDirects();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _achatsDirects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AchatDirect?> getAchatDirectById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final achatDirect = await _achatDirectService.getAchatDirectById(id);
      _error = null;
      return achatDirect;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AchatDirect?> createAchatDirect(AchatDirect achatDirect) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newAchatDirect = await _achatDirectService.createAchatDirect(achatDirect);
      _achatsDirects.add(newAchatDirect);
      _error = null;
      return newAchatDirect;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AchatDirect?> updateAchatDirect(String id, AchatDirect achatDirect) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedAchatDirect = await _achatDirectService.updateAchatDirect(id, achatDirect);
      final index = _achatsDirects.indexWhere((a) => a.id == id);
      if (index != -1) {
        _achatsDirects[index] = updatedAchatDirect;
      }
      _error = null;
      return updatedAchatDirect;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAchatDirect(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _achatDirectService.deleteAchatDirect(id);
      _achatsDirects.removeWhere((a) => a.id == id);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> generatePdf(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final pdfUrl = await _achatDirectService.generatePdf(id);
      _error = null;
      return pdfUrl;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}