import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class LoginService {
  static const String _loginUrl = '${AppConfig.baseUrl}/api/auth/login'; // Remplacez par l'URL de votre API
//192.168.1.23
//10.0.2.2
  static Future<Map<String, dynamic>> login(String email, String motDePasse) async {
    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'motDePasse': motDePasse}), // Utilisez 'motDePasse' ici
      );

      // Vérifie si la réponse est vide ou non valide
      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Réponse vide du serveur.'};
      }

      // Vérifie si la réponse est bien du JSON
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {'success': false, 'message': 'Format JSON invalide: ${response.body}'};
      }

      // Vérifie le statut de la réponse
      if (response.statusCode == 200 && responseData.containsKey('token')) {
        return {
          'success': true,
          'message': 'Connexion réussie.',
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur inconnue.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }
}
