import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/kadys_commentaire_model.dart';
import 'models/kadys_model.dart';

final kadysRepositoryProvider = Provider<KadysRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KadysRepository(apiClient);
});

class KadysRepository {
  final ApiClient _apiClient;

  KadysRepository(this._apiClient);

  Future<PageResponse<KadysModel>> getFeed({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.kadysFeed,
      queryParameters: {'page': page, 'size': size},
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('data') && rawData['data'] is Map<String, dynamic>) {
        return PageResponse<KadysModel>.fromJson(
          rawData['data'] as Map<String, dynamic>,
          (item) => KadysModel.fromJson(item),
        );
      }
      return PageResponse<KadysModel>.fromJson(
        rawData,
        (item) => KadysModel.fromJson(item),
      );
    }
    return const PageResponse(content: [], totalElements: 0, totalPages: 0, size: 10, number: 0);
  }

  Future<void> toggleLike(int id) async {
    await _apiClient.post(ApiEndpoints.kadysLike(id));
  }

  Future<void> enregistrerVue(int id) async {
    await _apiClient.post(ApiEndpoints.kadysVue(id));
  }

  Future<List<KadysCommentaireModel>> getCommentaires(int realisationId) async {
    final response = await _apiClient.get(ApiEndpoints.kadysCommentaires(realisationId));
    final rawData = response.data;
    if (rawData is List) {
      return rawData
          .map((item) => KadysCommentaireModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      return (rawData['data'] as List)
          .map((item) => KadysCommentaireModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<KadysCommentaireModel> ajouterCommentaire(int realisationId, String contenu) async {
    final response = await _apiClient.post(
      ApiEndpoints.kadysCommentaires(realisationId),
      data: {'contenu': contenu},
    );
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('data') && rawData['data'] is Map<String, dynamic>) {
        return KadysCommentaireModel.fromJson(rawData['data'] as Map<String, dynamic>);
      }
      return KadysCommentaireModel.fromJson(rawData);
    }
    throw Exception('Erreur lors de l\'ajout du commentaire');
  }
}

