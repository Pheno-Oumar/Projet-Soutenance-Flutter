import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/reclamation_model.dart';
import 'reclamation_mock_data.dart';

final reclamationRepositoryProvider = Provider<ReclamationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReclamationRepository(apiClient);
});

class ReclamationRepository {
  final ApiClient _apiClient;
  List<ReclamationModel> _localReclamations = List.from(ReclamationMockData.mockReclamations);

  ReclamationRepository(this._apiClient);

  Future<List<ReclamationModel>> listerMesReclamations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientReclamations);
      final apiResp = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as List<dynamic>,
      );

      if (apiResp.data != null && apiResp.data!.isNotEmpty) {
        return apiResp.data!
            .map((item) => ReclamationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Hors-ligne ou non connecté -> retour des données mock
    }
    return _localReclamations;
  }

  Future<ReclamationModel> getReclamationDetail(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientReclamationDetail(id));
      final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResp.data != null) {
        return ReclamationModel.fromJson(apiResp.data!);
      }
    } catch (_) {}

    return _localReclamations.firstWhere(
      (r) => r.id == id,
      orElse: () => _localReclamations.first,
    );
  }

  Future<ReclamationModel> creerReclamation({
    required String salonSlug,
    required String salonNom,
    required String salonAdresse,
    required String salonLogo,
    required String type,
    required String objet,
    required String description,
  }) async {
    final newId = DateTime.now().millisecondsSinceEpoch % 10000;
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final nouvelle = ReclamationModel(
      id: newId,
      codeReference: '#REC-${now.year}-${newId.toString().padLeft(4, '0')}',
      salonNom: salonNom,
      salonSlug: salonSlug,
      salonAdresse: salonAdresse,
      salonLogo: salonLogo,
      type: type,
      objet: objet,
      description: description,
      statut: 'EN_ATTENTE',
      dateCreation: dateStr,
    );

    try {
      await _apiClient.post(
        ApiEndpoints.clientReclamations,
        data: {
          'salonSlug': salonSlug,
          'type': type,
          'objet': objet,
          'description': description,
        },
      );
    } catch (_) {}

    _localReclamations = [nouvelle, ..._localReclamations];
    return nouvelle;
  }

  Future<void> relancerReclamation(int id) async {
    _localReclamations = _localReclamations.map((r) {
      if (r.id == id) {
        return r.copyWith(
          statut: 'EN_ATTENTE',
          reponseTraitement: null,
          reponseAuteur: null,
        );
      }
      return r;
    }).toList();
  }
}
