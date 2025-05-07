import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ClientService {
  static const String _baseUrl = '${AppConfig.baseUrl}/clients';

  // Headers communs pour toutes les requêtes
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Si vous utilisez l'authentification :
      // 'Authorization': 'Bearer $token',
    };
  }

  // Récupérer tous les clients
  static Future<List<dynamic>> fetchClients() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers,
      );

      print('[GET Clients] Status: ${response.statusCode}');
      print('[GET Clients] Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData is List ? decodedData : decodedData['data'] ?? [];
      } else {
        throw Exception(
          'Échec du chargement (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('[ERROR fetchClients] $e');
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  // Ajouter un nouveau client
  static Future<dynamic> addClient(Map<String, dynamic> clientData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode(clientData),
      );

      print('[POST Client] Status: ${response.statusCode}');
      print('[POST Client] Response: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Échec de l\'ajout (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('[ERROR addClient] $e');
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  static Future<Map> updateClient(String id, Map<String, dynamic> clientData) async {
    try {
      // Filtrage des champs autorisés
      final allowedKeys = [
        'nom',
        'prenom',
        'telephone',
        'adresse',
        'plafond_credit',
        'seuilRemise',
        'commercial_assigne',
        'retenuSourceC',
        'isActive',
        'entreprise',
        'matricule',
        'cin'
      ];

      final filteredClientData = Map.fromEntries(
        clientData.entries.where((e) => allowedKeys.contains(e.key))
      );

      print('Envoi des données de mise à jour : ${json.encode(filteredClientData)}');
    
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
        body: json.encode(filteredClientData),
      );

      final decodedResponse = json.decode(response.body);
      print('Réponse du serveur : $decodedResponse');

      if (response.statusCode == 200) {
        if (decodedResponse is Map && decodedResponse.containsKey('_id')) {
          return decodedResponse;
        } else {
          throw Exception('Réponse du serveur invalide: ${response.body}');
        }
      } else {
        throw Exception(
          'Échec de la mise à jour (${response.statusCode}): ${decodedResponse['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('[ERREUR updateClient] $e');
      throw Exception('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  // Supprimer un client
  static Future<bool> deleteClient(String id) async {
    try {
      print('[DELETE Client] ID: $id'); // Log supplémentaire
    
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
      );

      print('[DELETE Client] Status: ${response.statusCode}');
      print('[DELETE Client] Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return decodedResponse['success'] == true; // Adaptez selon votre API
      } else {
        throw Exception(
          'Échec de la suppression (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('[ERROR deleteClient] $e');
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }
}
