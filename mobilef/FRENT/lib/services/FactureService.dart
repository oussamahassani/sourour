import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/facture.dart';

class FactureService {
  final String baseUrl;

  FactureService({required this.baseUrl});

  // Create/save a new Facture
  Future<bool> createFacture(Facture facture) async {
    final url = Uri.parse('$baseUrl/factures');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(facture.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create facture: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating facture: $e');
      return false;
    }
  }

  // Fetch all factures
  Future<List<Facture>> fetchFactures() async {
    final url = Uri.parse('$baseUrl/factures');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Facture.fromJson(json)).toList();
      } else {
        print('Failed to fetch factures: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching factures: $e');
      return [];
    }
  }

  // Fetch single facture by id
  Future<Facture?> fetchFactureById(String id) async {
    final url = Uri.parse('$baseUrl/factures/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Facture.fromJson(data);
      } else {
        print('Failed to fetch facture by id: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching facture by id: $e');
      return null;
    }
  }

  // Optionally add update and delete methods here if needed later.
}
