import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/panier_model.dart';

final panierRepositoryProvider = Provider<PanierRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PanierRepository(apiClient);
});

class PanierRepository {
  final ApiClient _apiClient;

  PanierRepository(this._apiClient);

  Future<PanierModel?> getPanier({String? slugSalon}) async {
    final endpoint = slugSalon != null && slugSalon.isNotEmpty
        ? ApiEndpoints.salonPanier(slugSalon)
        : ApiEndpoints.clientPanier;

    try {
      final response = await _apiClient.get(endpoint);
      final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResp.data != null) {
        return PanierModel.fromJson(apiResp.data!);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<PanierModel> modifierQuantite({
    required String slugSalon,
    required int produitId,
    required int quantite,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.salonPanierArticle(slugSalon, produitId),
      data: {'quantite': quantite},
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return PanierModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Échec de mise à jour du panier');
  }

  Future<PanierModel> supprimerArticle({
    required String slugSalon,
    required int produitId,
  }) async {
    final response = await _apiClient.delete(
      ApiEndpoints.salonPanierArticle(slugSalon, produitId),
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return PanierModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Échec de suppression');
  }

  Future<void> viderPanier(String slugSalon) async {
    await _apiClient.delete(ApiEndpoints.salonPanier(slugSalon));
  }
}
