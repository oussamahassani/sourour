import 'package:intl/intl.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import '../models/achat.dart'; // For date formatting
import 'dart:convert';
import './article_service.dart';

class PurchaseService {
  static const String _baseUrl =
      '${AppConfig.baseUrl}/achat'; // Remplacez par l'URL de votre API
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Si vous utilisez l'authentification :
      // 'Authorization': 'Bearer $token',
    };
  }

  final Map<String, String> _articles = {'1': 'Article 1', '2': 'Article 2'};

  final Map<String, String> _suppliers = {};
  /*
  Future<void> initData() async {
    await Future.wait([getArticles(), getfetchSuppliers()]);
  }
*/
  Future<List<Map<String, String>>> getfetchSuppliers() async {
    final url = Uri.parse('${AppConfig.baseUrl}/fournisseurs');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        _suppliers.clear(); // optionnel si tu utilises un cache

        final suppliers =
            data
                .where(
                  (item) =>
                      item['_id'] != null &&
                      (item['nomF'] != null || item['prenomF'] != null),
                )
                .map<Map<String, String>>((supplier) {
                  final id = supplier['_id'];
                  final name =
                      supplier['nomF'] ?? supplier['nomF'] ?? 'Sans nom';
                  _suppliers[id] = name; // mise en cache (facultatif)
                  return {'id': id, 'name': name};
                })
                .toList();
        print(suppliers);

        return suppliers;
      } else {
        print('Erreur API fournisseurs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur de connexion fournisseurs: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getArticles() async {
    final url = Uri.parse('${AppConfig.baseUrl}/product');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        // Assurez-vous que chaque item a bien un 'id' et un 'name'
        return data
            .where(
              (item) =>
                  item['_id'] != null &&
                  (item['article'] != null || item['article'] != null),
            )
            .map<Map<String, String>>((item) {
              return {
                'id': item['_id'],
                'name': item['article'] ?? item['article'],
              };
            })
            .toList();
      } else {
        print('Erreur API product: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erreur de connexion product: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getSupplierss() async {
    if (_suppliers.isEmpty) {
      await getfetchSuppliers();
    }
    return _suppliers.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  final List<Purchase> _purchases = [];
  // Mock database (replace with actual database like Firestore or SQLite)
  static Future<List<Purchase>> fetchAchat() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final rawList = decodedData is List ? decodedData : decodedData ?? [];

        final dataJson =
            rawList.map<Purchase>((json) => Purchase.fromJson(json)).toList();
        return dataJson;
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

  // Mock article and supplier data

  // Save a purchase
  Future<bool> savePurchase(Purchase purchase) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      String type_achat = getPurchaseType(purchase);
      purchase.type_achat = type_achat;
      String jsonBody = jsonEncode(purchase.toJson());

      final response = await http.post(
        Uri.parse(_baseUrl+'/ajouter'),
        headers: headers,
        body: jsonBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _purchases.add(purchase);
        print('Purchase saved: ${purchase.toJson()}');
        return true;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saving purchase: $e');
      return false;
    }
  }

  // Fetch all purchases
  Future<List<Purchase>> getPurchases() async {
    // Simulate database fetch
    return _purchases;
  }

  // Delete a purchase
  Future<bool> deletePurchase(String id) async {
    try {
      _purchases.removeWhere((purchase) => purchase.id == id);
      return true;
    } catch (e) {
      print('Error deleting purchase: $e');
      return false;
    }
  }

  // Update a purchase (for modify action)
  Future<bool> updatePurchase(Purchase updatedPurchase) async {
    try {
      int index = _purchases.indexWhere((p) => p.id == updatedPurchase.id);
      if (index != -1) {
        _purchases[index] = updatedPurchase;
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating purchase: $e');
      return false;
    }
  }

  // Fetch suppliers
  Future<List<Map<String, String>>> getSuppliers() async {
    return _suppliers.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList();
  }

  // Resolve article name
  String getArticleName(String articleId) {
    return _articles[articleId] ?? 'Unknown Article';
  }

  // Resolve supplier name
  String getSupplierName(String supplierId) {
    return _suppliers[supplierId] ?? 'Unknown Supplier';
  }

  // Get purchase type (Direct or Commandé)
  String getPurchaseType(Purchase purchase) {
    return purchase.delaiLivraison != null ? 'Commandé' : 'Direct';
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
