class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    String message = 'Erreur réseau',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalException: originalException,
       );
}

class ServerException extends AppException {
  ServerException({
    String message = 'Erreur serveur',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'SERVER_ERROR',
         originalException: originalException,
       );
}

class ValidationException extends AppException {
  ValidationException({
    String message = 'Erreur de validation',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'VALIDATION_ERROR',
         originalException: originalException,
       );
}

class LocationException extends AppException {
  LocationException({
    String message = 'Erreur de localisation',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'LOCATION_ERROR',
         originalException: originalException,
       );
}
