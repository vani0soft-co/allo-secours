import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  // Clés de stockage
  static const String _favoriteServicesKey = 'favorite_services';
  static const String _userLocationKey = 'user_location';
  static const String _searchHistoryKey = 'search_history';
  static const String _userDataKey = 'user_data';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Favoris
  static Future<void> addFavorite(String serviceId) async {
    final favorites = getFavorites();
    if (!favorites.contains(serviceId)) {
      favorites.add(serviceId);
      await _prefs.setStringList(_favoriteServicesKey, favorites);
    }
  }

  static Future<void> removeFavorite(String serviceId) async {
    final favorites = getFavorites();
    favorites.remove(serviceId);
    await _prefs.setStringList(_favoriteServicesKey, favorites);
  }

  static List<String> getFavorites() {
    return _prefs.getStringList(_favoriteServicesKey) ?? [];
  }

  static bool isFavorite(String serviceId) {
    return getFavorites().contains(serviceId);
  }

  // Historique de recherche
  static Future<void> addSearchHistory(String query) async {
    final history = getSearchHistory();
    if (history.contains(query)) {
      history.remove(query);
    }
    history.insert(0, query);
    if (history.length > 20) {
      history.removeLast();
    }
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  static List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  static Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // Localisation utilisateur
  static Future<void> saveUserLocation(Map<String, dynamic> location) async {
    await _prefs.setString(_userLocationKey, jsonEncode(location));
  }

  static Map<String, dynamic>? getUserLocation() {
    final json = _prefs.getString(_userLocationKey);
    if (json != null) {
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return null;
  }

  // Données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Map<String, dynamic>? getUserData() {
    final json = _prefs.getString(_userDataKey);
    if (json != null) {
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return null;
  }

  // Utilitaires
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }
}
