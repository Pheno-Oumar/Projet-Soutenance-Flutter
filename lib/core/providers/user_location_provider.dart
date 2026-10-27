import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

class UserLocationState {
  final UserLocation? location;
  final bool isLoading;
  final bool hasRequested;

  const UserLocationState({
    this.location,
    this.isLoading = false,
    this.hasRequested = false,
  });

  UserLocationState copyWith({
    UserLocation? location,
    bool? isLoading,
    bool? hasRequested,
  }) {
    return UserLocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      hasRequested: hasRequested ?? this.hasRequested,
    );
  }
}

class UserLocationNotifier extends StateNotifier<UserLocationState> {
  UserLocationNotifier() : super(const UserLocationState()) {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final saved = await LocationService.getSavedLocation();
    if (saved != null) {
      state = state.copyWith(location: saved, hasRequested: true);
    }
  }

  /// Déclenche la demande de permission et récupère la position GPS
  Future<bool> requestLocation() async {
    state = state.copyWith(isLoading: true);
    final loc = await LocationService.requestAndGetCurrentLocation();
    state = state.copyWith(
      isLoading: false,
      location: loc ?? UserLocation.bamako,
      hasRequested: true,
    );
    return loc != null;
  }

  /// Ignorer la demande et continuer avec la position de référence Bamako
  void dismissPrompt() {
    LocationService.markLocationPrompted();
    state = state.copyWith(
      location: state.location ?? UserLocation.bamako,
      hasRequested: true,
    );
  }

  /// Calcule la distance en km vers un salon si les coordonnées sont valides
  double? getDistanceTo(double? salonLat, double? salonLng) {
    if (salonLat == null || salonLng == null) return null;
    final currentLoc = state.location ?? UserLocation.bamako;
    return LocationService.calculateDistanceKm(
      currentLoc.latitude,
      currentLoc.longitude,
      salonLat,
      salonLng,
    );
  }
}

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, UserLocationState>((ref) {
  return UserLocationNotifier();
});
