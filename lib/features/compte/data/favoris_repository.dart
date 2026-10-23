import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final favorisRepositoryProvider = Provider<FavorisRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavorisRepository(apiClient);
});

class FavorisRepository {
  final ApiClient _apiClient;

  static const String _keyLocalSalons = 'local_fav_salons';
  static const String _keyLocalCoiffures = 'local_fav_coiffures';
  static const String _keyLocalProduits = 'local_fav_produits';

  FavorisRepository(this._apiClient);

  // ==========================================
  // 1. GESTION LOCALE (MODE INVITÉ)
  // ==========================================

  Future<Set<String>> getLocalSalons() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalSalons) ?? [];
    return list.toSet();
  }

  Future<Set<int>> getLocalCoiffures() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalCoiffures) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toSet();
  }

  Future<Set<int>> getLocalProduits() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalProduits) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toSet();
  }

  Future<void> toggleLocalSalon(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalSalons) ?? [];
    if (list.contains(slug)) {
      list.remove(slug);
    } else {
      list.add(slug);
    }
    await prefs.setStringList(_keyLocalSalons, list);
  }

  Future<void> toggleLocalCoiffure(int varianteId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalCoiffures) ?? [];
    final idStr = varianteId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.add(idStr);
    }
    await prefs.setStringList(_keyLocalCoiffures, list);
  }

  Future<void> toggleLocalProduit(int produitId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyLocalProduits) ?? [];
    final idStr = produitId.toString();
    if (list.contains(idStr)) {
      list.remove(idStr);
    } else {
      list.add(idStr);
    }
    await prefs.setStringList(_keyLocalProduits, list);
  }

  Future<void> clearLocalFavoris() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLocalSalons);
    await prefs.remove(_keyLocalCoiffures);
    await prefs.remove(_keyLocalProduits);
  }

  // ==========================================
  // 2. APPELS DISTANTS (MODE CONNECTÉ)
  // ==========================================

  Future<List<Map<String, dynamic>>> getRemoteSalons() async {
    final response = await _apiClient.get(ApiEndpoints.clientFavorisSalons);
    final apiResp = ApiResponse<List<dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (apiResp.data != null) {
      return apiResp.data!.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> addRemoteSalon(String slug) async {
    await _apiClient.post(ApiEndpoints.clientFavoriSalonToggle(slug));
  }

  Future<void> removeRemoteSalon(String slug) async {
    await _apiClient.delete(ApiEndpoints.clientFavoriSalonToggle(slug));
  }

  Future<List<Map<String, dynamic>>> getRemoteCoiffures() async {
    final response = await _apiClient.get(ApiEndpoints.clientFavorisCoiffures);
    final apiResp = ApiResponse<List<dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (apiResp.data != null) {
      return apiResp.data!.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> addRemoteCoiffure(int varianteId) async {
    await _apiClient.post(ApiEndpoints.clientFavoriCoiffureToggle(varianteId));
  }

  Future<void> removeRemoteCoiffure(int varianteId) async {
    await _apiClient.delete(ApiEndpoints.clientFavoriCoiffureToggle(varianteId));
  }

  Future<List<Map<String, dynamic>>> getRemoteProduits() async {
    final response = await _apiClient.get(ApiEndpoints.clientFavorisProduits);
    final apiResp = ApiResponse<List<dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (apiResp.data != null) {
      return apiResp.data!.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> addRemoteProduit(int produitId) async {
    await _apiClient.post(ApiEndpoints.clientFavoriProduitToggle(produitId));
  }

  Future<void> removeRemoteProduit(int produitId) async {
    await _apiClient.delete(ApiEndpoints.clientFavoriProduitToggle(produitId));
  }

  // ==========================================
  // 3. SYNCHRONISATION INVITÉ -> BACKEND
  // ==========================================

  Future<void> synchroniserFavoris() async {
    final localSalons = await getLocalSalons();
    final localCoiffures = await getLocalCoiffures();
    final localProduits = await getLocalProduits();

    // 1. Pousser les salons favoris vers Spring Boot
    for (final slug in localSalons) {
      try {
        await addRemoteSalon(slug);
      } catch (_) {}
    }

    // 2. Pousser les coiffures favorites
    for (final id in localCoiffures) {
      try {
        await addRemoteCoiffure(id);
      } catch (_) {}
    }

    // 3. Pousser les produits favoris
    for (final id in localProduits) {
      try {
        await addRemoteProduit(id);
      } catch (_) {}
    }

    // 4. Nettoyer le cache local une fois poussé
    await clearLocalFavoris();
  }
}
