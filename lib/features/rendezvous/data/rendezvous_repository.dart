import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/rendezvous_model.dart';

final rendezVousRepositoryProvider = Provider<RendezVousRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RendezVousRepository(apiClient);
});

class RendezVousRepository {
  final ApiClient _apiClient;

  RendezVousRepository(this._apiClient);

  Future<PageResponse<RendezVousModel>> listerMesRendezVous({
    int page = 0,
    int size = 15,
    String? slugSalon,
    String? statut,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (slugSalon != null && slugSalon.isNotEmpty) {
        queryParams['slugSalon'] = slugSalon;
      }
      if (statut != null && statut.isNotEmpty && statut != 'TOUT') {
        queryParams['statut'] = statut;
      }

      final response = await _apiClient.get(
        ApiEndpoints.clientRendezVous,
        queryParameters: queryParams,
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

      final list = items
          .map((item) => RendezVousModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PageResponse<RendezVousModel>(
        content: list,
        totalElements: list.length,
        totalPages: 1,
        size: size,
        number: page,
      );
    } catch (_) {
      // Retourner une page vide au lieu de données statiques
      return PageResponse<RendezVousModel>(
        content: const [],
        totalElements: 0,
        totalPages: 0,
        size: size,
        number: page,
      );
    }
  }

  Future<RendezVousModel> getRendezVousDetail(int id) async {
    final response = await _apiClient.get(
      ApiEndpoints.clientRendezVousDetail(id),
    );

    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final dataField = raw['data'];
      if (dataField is Map<String, dynamic>) {
        return RendezVousModel.fromJson(dataField);
      }
    }
    throw Exception('Détail du rendez-vous introuvable');
  }

  Future<void> annulerRendezVous(
    int id, {
    String raison = 'Annulé par le client',
    String? slugSalon,
  }) async {
    final payload = {'motif': raison};

    if (slugSalon != null && slugSalon.isNotEmpty) {
      try {
        await _apiClient.post(
          '/$slugSalon/client/rendez-vous/$id/annuler',
          data: payload,
        );
        return;
      } catch (_) {}
    }

    await _apiClient.post(
      ApiEndpoints.clientRendezVousAnnuler(id),
      data: payload,
    );
  }
}
