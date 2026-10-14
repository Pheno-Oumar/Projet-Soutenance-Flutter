import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/rendezvous_model.dart';
import 'rendezvous_mock_data.dart';

final rendezVousRepositoryProvider = Provider<RendezVousRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RendezVousRepository(apiClient);
});

class RendezVousRepository {
  final ApiClient _apiClient;
  List<RendezVousModel> _localRendezVous = List.from(RendezVousMockData.mockRendezVous);

  RendezVousRepository(this._apiClient);

  Future<PageResponse<RendezVousModel>> listerMesRendezVous({
    int page = 0,
    int size = 15,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.clientRendezVous,
        queryParameters: {'page': page, 'size': size},
      );

      final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResp.data != null) {
        final parsed = PageResponse<RendezVousModel>.fromJson(
          apiResp.data!,
          (item) => RendezVousModel.fromJson(item),
        );
        if (parsed.content.isNotEmpty) {
          return parsed;
        }
      }
    } catch (_) {
      // API non connectée ou hors ligne -> fallback mock data
    }

    return PageResponse<RendezVousModel>(
      content: _localRendezVous,
      totalElements: _localRendezVous.length,
      totalPages: 1,
      size: size,
      number: page,
    );
  }

  Future<RendezVousModel> getRendezVousDetail(int id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.clientRendezVousDetail(id),
      );

      final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResp.data != null) {
        return RendezVousModel.fromJson(apiResp.data!);
      }
    } catch (_) {}

    final found = _localRendezVous.firstWhere(
      (r) => r.id == id,
      orElse: () => _localRendezVous.first,
    );
    return found;
  }

  Future<void> annulerRendezVous(int id, {String raison = 'Annulé par le client'}) async {
    try {
      await _apiClient.post(
        ApiEndpoints.clientRendezVousAnnuler(id),
        data: {'motif': raison},
      );
    } catch (_) {}

    // Mettre à jour le statut en local pour le retour instantané dans l'UI
    _localRendezVous = _localRendezVous.map((r) {
      if (r.id == id) {
        return r.copyWith(
          statut: 'ANNULE',
          motif: raison,
        );
      }
      return r;
    }).toList();
  }
}
