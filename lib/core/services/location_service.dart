import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final bool isDefault; // true si position par défaut (Bamako)

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  static const UserLocation bamako = UserLocation(
    latitude: 12.6392,
    longitude: -8.0029,
    isDefault: true,
  );
  static const UserLocation dakar = bamako; // Alias compatibilité
}

class LocationService {
  static const String _prefHasPromptedKey = 'user_location_has_prompted';
  static const String _prefPermissionGrantedKey = 'user_location_permission_granted';
  static const String _prefSavedLatKey = 'user_location_saved_lat';
  static const String _prefSavedLngKey = 'user_location_saved_lng';

  /// Vérifie si l'utilisateur a déjà été invité à partager sa position
  static Future<bool> hasPromptedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefHasPromptedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Marque que le prompt a été affiché
  static Future<void> markLocationPrompted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefHasPromptedKey, true);
    } catch (_) {}
  }

  /// Récupère la dernière position sauvegardée si disponible
  static Future<UserLocation?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasGranted = prefs.getBool(_prefPermissionGrantedKey) ?? false;
      if (!hasGranted) return null;

      final lat = prefs.getDouble(_prefSavedLatKey);
      final lng = prefs.getDouble(_prefSavedLngKey);
      if (lat != null && lng != null) {
        return UserLocation(latitude: lat, longitude: lng, isDefault: false);
      }
    } catch (_) {}
    return null;
  }

  /// Demande la permission et obtient la position GPS actuelle
  static Future<UserLocation?> requestAndGetCurrentLocation() async {
    await markLocationPrompted();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Le service de localisation est désactivé');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Permission de localisation refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Permission de localisation refusée définitivement');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefPermissionGrantedKey, true);
      await prefs.setDouble(_prefSavedLatKey, position.latitude);
      await prefs.setDouble(_prefSavedLngKey, position.longitude);

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        isDefault: false,
      );
    } catch (e) {
      debugPrint('[LocationService] Erreur lors de la récupération de la position : $e');
      return null;
    }
  }

  /// Formule Haversine pour calculer la distance exacte en km
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    final double dLon = (lon2 - lon1) * (math.pi / 180.0);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }
}
