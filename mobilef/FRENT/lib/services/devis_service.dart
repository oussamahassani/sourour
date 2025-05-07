import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config.dart';

class ApiService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/devis'; // Remplacez par votre URL

  // Méthode générique pour les requêtes HTTP
  static Future<dynamic> _request(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    String? token,
    File? file,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      http.Response response;

      if (method == 'GET') {
        response = await http.get(url, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          url,
          headers: headers,
          body: jsonEncode(body),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(url, headers: headers);
      } else {
        throw Exception('Méthode HTTP non supportée');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Erreur API: $e');
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // Gestion des devis
  static Future<List<dynamic>> getDevis(String token) async {
    return await _request('devis', 'GET', token: token);
  }

  static Future<dynamic> createDevis(Map<String, dynamic> devis, String token) async {
    return await _request('devis', 'POST', body: devis, token: token);
  }

  static Future<dynamic> updateDevis(String id, Map<String, dynamic> devis, String token) async {
    return await _request('devis/$id', 'PUT', body: devis, token: token);
  }

  static Future<void> deleteDevis(String id, String token) async {
    await _request('devis/$id', 'DELETE', token: token);
  }

  // Gestion des clients
  static Future<List<dynamic>> getClients(String token) async {
    return await _request('clients', 'GET', token: token);
  }

  static Future<dynamic> createClient(Map<String, dynamic> client, String token) async {
    return await _request('clients', 'POST', body: client, token: token);
  }

  // Gestion des articles
  static Future<List<dynamic>> getArticles(String token) async {
    return await _request('articles', 'GET', token: token);
  }

  static Future<dynamic> createArticle(Map<String, dynamic> article, String token) async {
    return await _request('articles', 'POST', body: article, token: token);
  }

  // Upload de fichier
  static Future<dynamic> uploadDevisImage(File image, String token) async {
    try {
      final url = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseData);
      } else {
        throw Exception('Erreur lors du téléchargement du fichier');
      }
    } catch (e) {
      debugPrint('Erreur upload: $e');
      throw Exception('Erreur lors du téléchargement du fichier');
    }
  }
}