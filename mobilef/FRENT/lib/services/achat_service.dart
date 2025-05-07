import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/achat.dart';
import '../config.dart';

class AchatDirectService {
  static final AchatDirectService _instance = AchatDirectService._internal();
  factory AchatDirectService() => _instance;
  AchatDirectService._internal();

  final String _baseUrl = '${AppConfig.baseUrl}/api/achats';

  Future<List<AchatDirect>> fetchAchatsDirects() async {
    final response = await http.get(Uri.parse('$_baseUrl/achats-directs'));
    
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => AchatDirect.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load achats directs: ${response.statusCode}');
    }
  }

  Future<AchatDirect> getAchatDirectById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/achats-directs/$id'));
    
    if (response.statusCode == 200) {
      return AchatDirect.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load achat direct: ${response.statusCode}');
    }
  }

  Future<AchatDirect> createAchatDirect(AchatDirect achatDirect) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/achats-directs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(achatDirect.toJson()),
    );
    
    if (response.statusCode == 201) {
      return AchatDirect.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create achat direct: ${response.statusCode} - ${response.body}');
    }
  }

  Future<AchatDirect> updateAchatDirect(String id, AchatDirect achatDirect) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/achats-directs/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(achatDirect.toJson()),
    );
    
    if (response.statusCode == 200) {
      return AchatDirect.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update achat direct: ${response.statusCode}');
    }
  }

  Future<void> deleteAchatDirect(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/achats-directs/$id'));
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete achat direct: ${response.statusCode}');
    }
  }

  Future<String> generatePdf(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/achats-directs/$id/pdf'));
    
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to generate PDF: ${response.statusCode}');
    }
  }
}