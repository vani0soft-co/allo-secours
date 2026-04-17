import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:allo_secours/models/location_model.dart';

class LocationProvider extends ChangeNotifier {
  Location? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _isSimulated = false;

  Location? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSimulated => _isSimulated;
  bool get hasLocation => _currentLocation != null;

  /// Demande la localisation réelle (GPS / navigateur)
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Sur web, on appelle directement getCurrentPosition
        // qui déclenche la popup de permission du navigateur
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        _setPosition(position, simulated: false);
      } else {
        // Mobile / desktop
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _error = permission == LocationPermission.deniedForever
              ? 'Localisation désactivée dans les paramètres'
              : 'Permission de localisation refusée';
          _isLoading = false;
          notifyListeners();
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _setPosition(position, simulated: false);
      }
    } catch (e) {
      // Sur web : l'utilisateur a bloqué la permission ou le navigateur n'a pas GPS
      _error = kIsWeb
          ? 'Localisation bloquée — utilisez la position simulée ou autorisez la géolocalisation dans Edge'
          : 'Erreur: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Utilise une position simulée (Paris par défaut, modifiable)
  void useSimulatedLocation({double lat = 6.3654, double lon = 2.4183, String city = 'Cotonou'}) {
    _currentLocation = Location(
      latitude: lat,
      longitude: lon,
      address: 'Position simulée — $city',
      city: city,
      country: 'Bénin',
      accuracy: 0,
    );
    _isSimulated = true;
    _error = null;
    notifyListeners();
  }

  void _setPosition(Position position, {required bool simulated}) {
    _currentLocation = Location(
      latitude: position.latitude,
      longitude: position.longitude,
      address: 'Votre position',
      city: '',
      country: '',
      accuracy: position.accuracy,
    );
    _isSimulated = simulated;
    _error = null;
  }

  double calculateDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  void clear() {
    _currentLocation = null;
    _isSimulated = false;
    _error = null;
    notifyListeners();
  }
}
