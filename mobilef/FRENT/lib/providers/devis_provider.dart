import 'dart:io';
import 'package:flutter/material.dart';
import '../services/devis_service.dart';

class ApiProvider with ChangeNotifier {
  String? _token;
  List<dynamic> _devis = [];
  List<dynamic> _clients = [];
  List<dynamic> _articles = [];

  List<dynamic> get devis => _devis;
  List<dynamic> get clients => _clients;
  List<dynamic> get articles => _articles;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  Future<void> fetchDevis() async {
    if (_token == null) return;
    _devis = await ApiService.getDevis(_token!);
    notifyListeners();
  }

  Future<void> addDevis(Map<String, dynamic> data) async {
    if (_token == null) return;
    await ApiService.createDevis(data, _token!);
    await fetchDevis();
  }

  Future<void> updateDevis(String id, Map<String, dynamic> data) async {
    if (_token == null) return;
    await ApiService.updateDevis(id, data, _token!);
    await fetchDevis();
  }

  Future<void> deleteDevis(String id) async {
    if (_token == null) return;
    await ApiService.deleteDevis(id, _token!);
    await fetchDevis();
  }

  Future<void> fetchClients() async {
    if (_token == null) return;
    _clients = await ApiService.getClients(_token!);
    notifyListeners();
  }

  Future<void> addClient(Map<String, dynamic> data) async {
    if (_token == null) return;
    await ApiService.createClient(data, _token!);
    await fetchClients();
  }

  Future<void> fetchArticles() async {
    if (_token == null) return;
    _articles = await ApiService.getArticles(_token!);
    notifyListeners();
  }

  Future<void> addArticle(Map<String, dynamic> data) async {
    if (_token == null) return;
    await ApiService.createArticle(data, _token!);
    await fetchArticles();
  }

  Future<dynamic> uploadImage(File file) async {
    if (_token == null) return null;
    return await ApiService.uploadDevisImage(file, _token!);
  }
}
