// lib/services/paiement_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/paiement.dart';

class PaiementService {
    static const String _baseUrl = '${AppConfig.baseUrl}/payment';

  // Get all paiements
  Future<List<Paiement>> fetchPaiements() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Paiement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load paiements');
    }
  }

  // Create a new paiement
  Future<Paiement> createPaiement(Paiement paiement) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paiement.toJson()),
    );
    if (response.statusCode == 201) {
      return Paiement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create paiement');
    }
  }

  // Update a paiement
  Future<Paiement> updatePaiement(String id, Paiement paiement) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(paiement.toJson()),
    );
    if (response.statusCode == 200) {
      return Paiement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update paiement');
    }
  }

  // Delete a paiement
  Future<void> deletePaiement(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete paiement');
    }
  }
}
