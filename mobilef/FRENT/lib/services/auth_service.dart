import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/auth'; // Remplacez par l'URL de votre API
//192.168.1.23
//10.0.2.2
  static Future<http.Response> signup(String nom, String prenom, String telephone, String email, String motDePasse) async {
    final url = Uri.parse('$_baseUrl/signup');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'motDePasse': motDePasse,
      }),
    );
    
    return response;
  }

  
}
