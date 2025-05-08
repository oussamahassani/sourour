import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../services/user_rh_service.dart';

class UserRhProvider with ChangeNotifier {
  final UserRhService _service;

  UserRhProvider(this._service);

  List<Employee> _employees = [];
  bool _isLoading = false;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      _employees = await _service.fetchEmployees();
    } catch (e) {
      print('Error fetching employees: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
