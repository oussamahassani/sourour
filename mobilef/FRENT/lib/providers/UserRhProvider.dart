import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart'; // Import the Employee class

class UserRhProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://your-api-url.com/user'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _employees = data.map((e) => Employee.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
