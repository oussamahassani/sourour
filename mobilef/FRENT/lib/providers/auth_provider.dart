import 'dart:io';
import 'package:flutter/material.dart';
import '../services/login_service.dart'; // Vérifie que le chemin est correct

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _token; // Le token peut être null

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get token => _token;

  Future<void> login(String email, String motDePasse) async {
    _isLoading = true;
    _errorMessage = ''; // Réinitialiser l'erreur avant une nouvelle tentative
    notifyListeners();

    try {
      final response = await LoginService.login(email, motDePasse);

      if (response['success']) {
        _token = response['token'];
        _errorMessage = '';
      } else {
        _errorMessage = response['message'];
      }
    } on SocketException catch (_) {
      _errorMessage = 'Problème de connexion Internet.';
    } on FormatException catch (_) {
      _errorMessage = 'Réponse du serveur invalide.';
    } catch (e) {
      _errorMessage = 'Erreur inattendue: ${e.toString()}';
      print(e.toString()); // Debugging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null; // Réinitialisation du token
    notifyListeners();
  }
}
