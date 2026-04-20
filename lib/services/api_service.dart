import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/models/review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  // Pour accéder depuis un vrai téléphone/émulateur:
  // 'http://10.0.2.2:3000/api/v1' (Android)
  // ou utiliser l'adresse IP réelle du serveur

  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        contentType: Headers.jsonContentType,
      ),
    );

    // Ajouter l'interceptor pour les tokens
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Erreur API: ${error.response?.statusCode} - ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // Charger le token depuis le stockage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Supprimer le token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Récupérer les services
  Future<List<Service>> getServices({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (category != null) queryParams['category'] = category;
      if (searchQuery != null) queryParams['search'] = searchQuery;

      final response = await _dio.get(
        '/services',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((service) => Service.fromJson(service as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur de chargement des services');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les détails d'un service
  Future<Service> getServiceDetail(String serviceId) async {
    try {
      final response = await _dio.get('/services/$serviceId');

      if (response.statusCode == 200) {
        return Service.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Erreur de chargement');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les services proches
  Future<List<Service>> getNearbyServices(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    String? category,
  }) async {
    try {
      final radiusMeters = radiusKm * 1000;

      final response = await _dio.post(
        '/services/nearby',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusMeters,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((service) => Service.fromJson(service as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur de chargement des services proches');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les avis d'un service
  Future<List<Review>> getServiceReviews(String serviceId) async {
    try {
      final response = await _dio.get('/services/$serviceId/reviews');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((review) => Review.fromJson(review as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur de chargement des avis');
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter un avis
  Future<Review> addReview({
    required String serviceId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/services/$serviceId/reviews',
        data: {
          'userId': userId,
          'userName': userName,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 201) {
        return Review.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de l\'ajout de l\'avis');
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher les urgences
  Future<List<Service>> getEmergencyServices(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.post(
        '/services/nearby',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'category': 'emergency',
          'radius': 10000, // 10km
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((service) => Service.fromJson(service as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur de chargement des urgences');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== AUTHENTIFICATION ====================

  // Inscription
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'passwordConfirm': password,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      }
      throw Exception('Erreur lors de l\'inscription');
    } catch (e) {
      rethrow;
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      }
      throw Exception('Email ou mot de passe incorrect');
    } catch (e) {
      rethrow;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await clearToken();
  }

  // Récupérer le profil
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Erreur de chargement du profil');
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour la localisation
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _dio.post(
        '/auth/location',
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter aux favoris
  Future<void> addFavorite(String serviceId) async {
    try {
      await _dio.post('/auth/favorites/$serviceId');
    } catch (e) {
      rethrow;
    }
  }

  // Retirer des favoris
  Future<void> removeFavorite(String serviceId) async {
    try {
      await _dio.delete('/auth/favorites/$serviceId');
    } catch (e) {
      rethrow;
    }
  }
}
