// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _authTokenKey = 'auth_token'; // Constante pour la clé du token
  static final _storage = FlutterSecureStorage();

  // Sauvegarder un token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      print("Erreur lors de la sauvegarde du token: $e");
      throw Exception("Impossible de sauvegarder le token");
    }
  }

  // Récupérer le token
  static Future<String?> get getToken async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      print("Erreur lors de la récupération du token: $e");
      throw Exception("Impossible de récupérer le token");
    }
  }

  // Supprimer le token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
    } catch (e) {
      print("Erreur lors de la suppression du token: $e");
      throw Exception("Impossible de supprimer le token");
    }
  }

  // Vérifier si un token existe
  static Future<bool> hasToken() async {
    try {
      return await _storage.containsKey(key: _authTokenKey);
    } catch (e) {
      print("Erreur lors de la vérification du token: $e");
      throw Exception("Impossible de vérifier le token");
    }
  }

  // Méthode générique pour stocker d'autres données sécurisées
  static Future<void> saveData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print("Erreur lors de la sauvegarde des données: $e");
      throw Exception("Impossible de sauvegarder les données");
    }
  }

  // Méthode générique pour récupérer d'autres données sécurisées
  static Future<String?> getData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
      throw Exception("Impossible de récupérer les données");
    }
  }

  // Méthode générique pour supprimer d'autres données sécurisées
  static Future<void> deleteData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print("Erreur lors de la suppression des données: $e");
      throw Exception("Impossible de supprimer les données");
    }
  }

  static getUserId() {}

  static getRole() {}

  static saveUserId(String s) {}

  static saveRole(String s) {}

  static deleteUserId() {}

  static deleteRole() {}
}