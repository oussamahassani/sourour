import 'package:flutter/material.dart';
import '../services/client_service.dart';

class ClientProvider with ChangeNotifier {
  List<dynamic> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _clients = await ClientService.fetchClients();
      _errorMessage = null;
    } catch (e) {
      _clients = [];
      _errorMessage = _getErrorMessage(e);
      debugPrint('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addClient(Map<String, dynamic> clientData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final newClient = await ClientService.addClient(clientData);
      if (newClient != null) {
        _clients.insert(0, newClient); // Add to the beginning of the list
        _errorMessage = null;
        return true;
      }
      _errorMessage = 'Failed to add client';
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Error adding client: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
Future<bool> updateClient(String id, Map<String, dynamic> clientData) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // ✅ Filtrer les champs autorisés ici
    final allowedKeys = [
      'nom',
      'prenom',
      'telephone',
      'adresse',
      'plafond_credit',
      'seuilRemise',
      'commercial_assigne',
      'retenuSourceC',
      'isActive',
      'entreprise',
      'matricule',
      'cin'
    ];

    final filteredClientData = Map.fromEntries(
      clientData.entries.where((e) => allowedKeys.contains(e.key))
    );

    // ✅ Utiliser les données filtrées
    final updatedClient = await ClientService.updateClient(id, filteredClientData);
    final updatedClientData = updatedClient['data'];

    if (updatedClientData != null) {
      final index = _clients.indexWhere((client) => _getClientId(client) == id);

      if (index != -1) {
        _clients[index] = {
          ..._clients[index] as Map<String, dynamic>,
          ...updatedClientData,
        };
        _errorMessage = null;
        return true;
      }
    }

    _errorMessage = 'Client non trouvé ou échec de la mise à jour.';
    return false;
  } catch (e) {
    _errorMessage = _getErrorMessage(e);
    debugPrint('Error updating client: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<bool> deleteClient(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await ClientService.deleteClient(id);
      if (success) {
        _clients.removeWhere((client) => _getClientId(client) == id);
        _errorMessage = null;
        return true;
      }
      _errorMessage = 'Failed to delete client';
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      debugPrint('Error deleting client: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get client ID consistently
  String _getClientId(dynamic client) {
    return (client['_id']?.toString() ?? client['idCL']?.toString() ?? '');
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    
    final errorStr = error.toString();
    
    if (errorStr.contains('Connection failed') || 
        errorStr.contains('Network is unreachable')) {
      return 'Erreur de connexion. Vérifiez votre internet';
    }
    else if (errorStr.contains('404')) {
      return 'Ressource introuvable';
    }
    else if (errorStr.contains('401') || errorStr.contains('403')) {
      return 'Accès non autorisé';
    }
    else if (errorStr.contains('500')) {
      return 'Erreur serveur. Veuillez réessayer plus tard';
    }
    else if (errorStr.contains('email already exists')) {
      return 'Cet email est déjà utilisé';
    }
    
    return 'Une erreur est survenue. Veuillez réessayer';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Improved search function
  List<dynamic> searchClients(String query) {
    if (query.isEmpty) return _clients;
    
    final queryLower = query.toLowerCase();
    return _clients.where((client) {
      final name = client['nom']?.toString().toLowerCase() ?? '';
      final firstName = client['prenom']?.toString().toLowerCase() ?? '';
      final email = client['email']?.toString().toLowerCase() ?? '';
      final phone = client['telephone']?.toString() ?? '';
      
      return name.contains(queryLower) || 
             firstName.contains(queryLower) || 
             email.contains(queryLower) || 
             phone.contains(queryLower);
    }).toList();
  }
}