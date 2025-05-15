import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/achat.dart';

class PurchaseService {
  static const String _baseUrl = '${AppConfig.baseUrl}/achat';
  static const String _fournisseurUrl = '${AppConfig.baseUrl}/fournisseurs';
  static const String _articleUrl = '${AppConfig.baseUrl}/product';
  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<List<Map<String, String>>> getfetchSuppliers() async {
    final url = Uri.parse(_fournisseurUrl);
    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);
      print('Raw supplier response: ${response.body}'); // Log raw response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! List) {
          print('Erreur: Supplier response is not a list: $data');
          return [];
        }
        final suppliers = data
            .where((item) => item['_id'] != null)
            .map<Map<String, String>>((supplier) {
              final id = supplier['_id'].toString();
              final name = '${supplier['prenomF'] ?? ''} ${supplier['nomF'] ?? ''}'.trim();
              return {
                'id': id,
                'name': name.isEmpty ? 'Fournisseur ID: $id' : name,
              };
            }).toList();
        print('Fetched suppliers: $suppliers');
        return suppliers;
      } else {
        print('Erreur API fournisseurs: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erreur de connexion fournisseurs: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getArticles() async {
    final url = Uri.parse(_articleUrl);
    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);
      print('Raw article response: ${response.body}'); // Log raw response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! List) {
          print('Erreur: Article response is not a list: $data');
          return [];
        }
        final articles = data
            .where((item) => item['_id'] != null && item['article'] != null)
            .map<Map<String, String>>((item) {
              return {
                'id': item['_id'].toString(),
                'name': item['article'].toString(),
              };
            }).toList();
        print('Fetched articles: $articles');
        return articles;
      } else {
        print('Erreur API articles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Erreur de connexion articles: $e');
      return [];
    }
  }

  Future<List<Purchase>> fetchPurchases() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/liste'), headers: _headers).timeout(_timeout);
      print('Raw purchase response: ${response.body}'); // Log raw response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> purchaseList;
        if (data is List) {
          purchaseList = data;
        } else if (data is Map && data.containsKey('data')) {
          purchaseList = data['data'] as List<dynamic>;
        } else if (data is Map) {
          // Handle single object case
          purchaseList = [data];
        } else {
          throw Exception('Unexpected response format: $data');
        }
        return purchaseList.map((json) => Purchase.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('Erreur fetchPurchases: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<bool> savePurchase(Purchase purchase) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ajouter'),
        headers: _headers,
        body: jsonEncode(purchase.toJson()),
      ).timeout(_timeout);
      if (response.statusCode == 201) {
        print('Achat enregistré: ${response.body}');
        return true;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur savePurchase: $e');
      return false;
    }
  }

  Future<bool> deletePurchase(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/supprimer/$id'),
        headers: _headers,
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur deletePurchase: $e');
      return false;
    }
  }

  Future<bool> updatePurchase(Purchase purchase) async {
    if (purchase.id == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/modifier/${purchase.id}'),
        headers: _headers,
        body: jsonEncode(purchase.toJson()),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur updatePurchase: $e');
      return false;
    }
  }
}
