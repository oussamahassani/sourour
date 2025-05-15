import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Employee.dart';
import '../config.dart';
import '../models/User.dart';

class UserRhService {
  static const String baseUrl = '${AppConfig.baseUrl}/user';

  static Future<List<User>> fetchALLadmin() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/admin/liste'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  static Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse('${baseUrl}/employees'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  static Future<void> createEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/employees'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Échec de la création de l\'employé');
    }
  }
}
