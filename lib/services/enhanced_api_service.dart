import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/models/review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}

class EnhancedApiService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  late Dio _dio;
  late Dio _dioWithRetry;
  String? _token;
  bool _isOnline = true;
  int _retryCount = 0;

  bool get isOnline => _isOnline;
  int get retryCount => _retryCount;

  EnhancedApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    // Configuration de base DIO
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Avec retry automatique
    _dioWithRetry = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Interceptors
    _dio.interceptors.add(_createInterceptor());
    _dioWithRetry.interceptors.add(_createInterceptor());
    _dioWithRetry.interceptors.add(_createRetryInterceptor());
  }

  InterceptorsWrapper _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _isOnline = true;
        notifyListeners();
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.unknown) {
          _isOnline = false;
          notifyListeners();
        }
        return handler.next(error);
      },
    );
  }

  InterceptorsWrapper _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        final isRetryable = error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError;

        if (isRetryable && _retryCount < _maxRetries) {
          _retryCount++;
          await Future.delayed(_retryDelay);

          try {
            final request = error.requestOptions;
            final response = await _dioWithRetry.request(
              request.path,
              data: request.data,
              queryParameters: request.queryParameters,
              options: Options(
                method: request.method,
                headers: request.headers,
              ),
            );
            _retryCount = 0;
            return handler.resolve(response);
          } catch (e) {
            if (_retryCount < _maxRetries) {
              return handler.next(error);
            }
          }
        }

        _retryCount = 0;
        return handler.next(error);
      },
    );
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<List<Service>> getServices({
    String? category,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (category != null) queryParams['category'] = category;
      if (searchQuery != null) queryParams['search'] = searchQuery;

      final response = await _dioWithRetry.get(
        '/services',
        queryParameters: queryParams,
      );

      _handleResponse(response);

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((service) => Service.fromJson(service as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Service> getServiceDetail(String serviceId) async {
    try {
      final response = await _dioWithRetry.get('/services/$serviceId');

      _handleResponse(response);

      return Service.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Service>> getNearbyServices(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
    String? category,
  }) async {
    try {
      final radiusMeters = radiusKm * 1000;

      final response = await _dioWithRetry.post(
        '/services/nearby',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusMeters,
          if (category != null) 'category': category,
        },
      );

      _handleResponse(response);

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((service) => Service.fromJson(service as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Review>> getServiceReviews(String serviceId) async {
    try {
      final response = await _dioWithRetry.get('/services/$serviceId/reviews');

      _handleResponse(response);

      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Review> addReview(String serviceId, Review review) async {
    try {
      final response = await _dioWithRetry.post(
        '/services/$serviceId/reviews',
        data: review.toJson(),
      );

      _handleResponse(response);

      return Review.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode == null ||
        response.statusCode! >= 400 && response.statusCode! < 500) {
      final message = response.data['message'] ?? 'Une erreur est survenue';
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
      );
    }
  }

  ApiException _handleError(DioException error) {
    String message = 'Une erreur est survenue';

    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Délai d\'expiration de la connexion';
      _isOnline = false;
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Délai d\'expiration de réception';
      _isOnline = false;
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Erreur de connexion réseau';
      _isOnline = false;
    } else if (error.response != null) {
      message = error.response?.data['message'] ?? error.message ?? message;
    } else {
      message = error.message ?? message;
    }

    notifyListeners();
    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      originalException: error,
    );
  }
}
