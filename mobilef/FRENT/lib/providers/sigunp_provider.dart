import 'dart:convert' show json;

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> signup(String nom, String prenom, String telephone, String email, String motDePasse) async {
    isLoading = true;

    try {
      final response = await AuthService.signup(nom, prenom, telephone, email, motDePasse);

      if (response.statusCode == 201) {
        // Inscription réussie
        print('Inscription réussie');
      } else {
        final responseBody = json.decode(response.body);
        String errorMessage = responseBody['message'] ?? 'Une erreur est survenue.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Une erreur est survenue lors de l\'inscription: $e');
    } finally {
      isLoading = false;
    }
  }
}

