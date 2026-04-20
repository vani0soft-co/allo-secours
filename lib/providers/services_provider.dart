import 'package:flutter/material.dart';
import 'package:allo_secours/models/service_model.dart';
import 'package:allo_secours/services/api_service.dart';
import 'package:allo_secours/utils/mock_data.dart';

class ServicesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  final List<Service> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Service> get allServices => _allServices;
  List<Service> get filteredServices => _filteredServices;
  List<Service> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServices({String? category, String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allServices = await _apiService.getServices(
        category: category,
        searchQuery: searchQuery,
      );
      _filteredServices = _allServices;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filterServices(searchQuery);
      }
      _error = null;
    } catch (e) {
      // Serveur inaccessible → données mock instantanées
      _allServices = category != null
          ? MockData.getServicesByCategory(category)
          : MockData.mockServices;
      _filteredServices = _allServices;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      _filteredServices = _allServices;
    } else {
      _filteredServices = _allServices
          .where(
            (service) =>
                service.name.toLowerCase().contains(query.toLowerCase()) ||
                service.address.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    _filteredServices = _allServices
        .where((service) => service.category == category)
        .toList();
    notifyListeners();
  }

  void filterByRating(double minRating) {
    _filteredServices = _allServices
        .where((service) => service.rating >= minRating)
        .toList();
    notifyListeners();
  }

  void sortByDistance() {
    _filteredServices.sort((a, b) => a.distance.compareTo(b.distance));
    notifyListeners();
  }

  void sortByRating() {
    _filteredServices.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  void toggleFavorite(Service service) {
    final index = _favorites.indexWhere((fav) => fav.id == service.id);
    if (index != -1) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(service);
    }
    notifyListeners();
  }

  bool isFavorite(String serviceId) {
    return _favorites.any((fav) => fav.id == serviceId);
  }

  Future<Service?> getServiceDetail(String serviceId) async {
    try {
      return await _apiService.getServiceDetail(serviceId);
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return null;
    }
  }
}
