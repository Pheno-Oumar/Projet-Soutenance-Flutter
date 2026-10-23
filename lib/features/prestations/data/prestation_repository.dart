import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/prestation_model.dart';

final prestationRepositoryProvider = Provider<PrestationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PrestationRepository(apiClient);
});

class PrestationRepository {
  final ApiClient _apiClient;

  PrestationRepository(this._apiClient);

  Future<List<PrestationModel>> listerMesPrestations({
    String? slugSalon,
    String? statut,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (slugSalon != null && slugSalon.isNotEmpty) {
        queryParams['slugSalon'] = slugSalon;
      }
      if (statut != null && statut.isNotEmpty && statut != 'TOUT') {
        queryParams['statut'] = statut;
      }

      final response = await _apiClient.get(
        ApiEndpoints.clientPrestations,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final raw = response.data;
      List<dynamic> items = [];

      if (raw is Map<String, dynamic>) {
        final dataField = raw['data'];
        if (dataField is List) {
          items = dataField;
        } else if (dataField is Map<String, dynamic> && dataField['content'] is List) {
          items = dataField['content'] as List;
        }
      } else if (raw is List) {
        items = raw;
      }

      return items
          .map((item) => PrestationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<PrestationModel> getPrestationDetail(int id) async {
    final response = await _apiClient.get(
      ApiEndpoints.clientPrestationDetail(id),
    );

    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final dataField = raw['data'];
      if (dataField is Map<String, dynamic>) {
        return PrestationModel.fromJson(dataField);
      }
    }
    throw Exception('Détail de la prestation introuvable');
  }
}
