import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:allo_secours/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  String get userName {
    if (_user == null) return 'Utilisateur';
    final first = _user!['firstName'] ?? '';
    final last = _user!['lastName'] ?? '';
    return '$first $last'.trim().isEmpty ? 'Utilisateur' : '$first $last'.trim();
  }

  String get userEmail => _user?['email'] ?? '';
  String get userId => _user?['id'] ?? _user?['_id'] ?? '';

  /// Initialise l'état d'auth depuis le stockage local
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final firstName = prefs.getString('user_firstName');
    final lastName = prefs.getString('user_lastName');
    final email = prefs.getString('user_email');
    final id = prefs.getString('user_id');

    if (_token != null && firstName != null) {
      _isAuthenticated = true;
      _user = {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
      await _apiService.loadToken();
    }
    notifyListeners();
  }

  /// Connexion utilisateur
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email: email, password: password);
      await _saveSession(data);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription utilisateur
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      await _saveSession(data);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_firstName');
    await prefs.remove('user_lastName');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('search_history');

    _isAuthenticated = false;
    _token = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Connexion en mode démo (sans backend)
  Future<void> loginAsDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'demo_token');
    await prefs.setString('user_firstName', 'Giovani Ismaël');
    await prefs.setString('user_lastName', 'Farid');
    await prefs.setString('user_email', 'giovani@example.com');
    await prefs.setString('user_id', 'demo_user_1');

    _token = 'demo_token';
    _isAuthenticated = true;
    _user = {
      'id': 'demo_user_1',
      'firstName': 'Giovani Ismaël',
      'lastName': 'Farid',
      'email': 'giovani@example.com',
    };
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = data['user'] ?? data['data'] ?? data;
    final token = data['token'] as String?;

    if (token != null) {
      await prefs.setString('auth_token', token);
      _token = token;
    }
    await prefs.setString('user_firstName', userData['firstName']?.toString() ?? '');
    await prefs.setString('user_lastName', userData['lastName']?.toString() ?? '');
    await prefs.setString('user_email', userData['email']?.toString() ?? '');
    await prefs.setString('user_id', (userData['_id'] ?? userData['id'] ?? '').toString());

    _user = {
      'id': (userData['_id'] ?? userData['id'] ?? '').toString(),
      'firstName': userData['firstName']?.toString() ?? '',
      'lastName': userData['lastName']?.toString() ?? '',
      'email': userData['email']?.toString() ?? '',
    };
  }

  String _parseError(String error) {
    if (error.contains('401') || error.contains('incorrect')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.contains('400') || error.contains('exists')) {
      return 'Cet email est déjà utilisé';
    } else if (error.contains('connection') || error.contains('SocketException')) {
      return 'Impossible de se connecter au serveur';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
