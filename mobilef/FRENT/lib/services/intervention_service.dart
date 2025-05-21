import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Employee.dart';
import '../config.dart';
import '../models/InterventionReport.dart';
import '../models/Intervention.dart';

class InterventionService {
  static const String baseUrl = '${AppConfig.baseUrl}/intervention';
  /*
  static Future<List<Intervention>> fetchALLIntrevention() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Intervention.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }
*/
  static Future<List<InterventionReport>> fetchAllRepport() async {
    final response = await http.get(Uri.parse('${baseUrl}/all/report'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => InterventionReport.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  static Future<bool> deleteRepport(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/report/$id'),
      );
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

  static Future<void> createReport(InterventionReport employee) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/ajouterRepport'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Échec de la création de l\'employé');
    }
  }

  static Future<void> createIntervention(Intervention employee) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/ajouter'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Échec de la création de l\'employé');
    }
  }
}
