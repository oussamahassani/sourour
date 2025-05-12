import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fournisseur.dart';

class FournisseurService {
  final String baseUrl;
  final String endpoint = '/fournisseurs';
  final Duration timeout = const Duration(seconds: 30);

  FournisseurService({required this.baseUrl, required http.Client client});

  Future<List<Fournisseur>> getFournisseurs() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(timeout);

      return _handleListResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  Future<Fournisseur> createFournisseur(Fournisseur fournisseur) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: json.encode(fournisseur.toJson()),
          )
          .timeout(timeout);

      return _handleSingleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion lors de la création: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la création: $e');
    }
  }

  Future<Fournisseur> updateFournisseur(
    String id,
    Fournisseur fournisseur,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint/$id'),
            headers: _getHeaders(),
            body: json.encode(fournisseur.toJson()),
          )
          .timeout(timeout);

      return _handleSingleResponse(response);
    } on http.ClientException catch (e) {
      throw Exception(
        'Erreur de connexion lors de la mise à jour: ${e.message}',
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  Future<void> deleteFournisseur(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Échec de suppression. Code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Erreur de connexion lors de la suppression: ${e.message}',
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  Future<List<Fournisseur>> searchFournisseurs(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl$endpoint/search?q=${Uri.encodeQueryComponent(query)}',
            ),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      return _handleListResponse(response);
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion lors de la recherche: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // Méthodes helpers
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Ajoute ici d'autres headers si besoin, ex: Auth
      // 'Authorization': 'Bearer ton_token',
    };
  }

  Fournisseur _handleSingleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Fournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception('''
        Erreur serveur: ${response.statusCode}
        Message: ${response.body.isNotEmpty ? response.body : 'Aucun détail'}
      ''');
    }
  }

  List<Fournisseur> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return (data as List).map((item) => Fournisseur.fromJson(item)).toList();
    } else {
      throw Exception('''
        Erreur serveur: ${response.statusCode}
        Message: ${response.body.isNotEmpty ? response.body : 'Aucun détail'}
      ''');
    }
  }
}
