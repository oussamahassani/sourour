import 'dart:convert';
import 'package:http/http.dart' as http;
import 'employee_model.dart';
import '../config.dart';

class UserRhService {
  final String baseUrl='${AppConfig.baseUrl}/user'; 

  UserRhService({required this.baseUrl});

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

}
