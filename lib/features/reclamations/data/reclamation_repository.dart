import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/reclamation_model.dart';

final reclamationRepositoryProvider = Provider<ReclamationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReclamationRepository(apiClient);
});

class ReclamationRepository {
  final ApiClient _apiClient;

  ReclamationRepository(this._apiClient);

  Future<List<ReclamationModel>> listerMesReclamations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientReclamations);
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return data
              .map((item) => ReclamationModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<ReclamationModel> getReclamationDetail(int id) async {
    final response = await _apiClient.get(ApiEndpoints.clientReclamationDetail(id));
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return ReclamationModel.fromJson(data);
      }
    }
    throw Exception('Détail de la réclamation introuvable');
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
    final response = await _apiClient.post(
      ApiEndpoints.clientReclamations,
      data: {
        'slugSalon': salonSlug,
        'type': type,
        'objet': objet,
        'description': description,
      },
      queryParameters: {
        'slugSalon': salonSlug,
      },
    );

    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return ReclamationModel.fromJson(data);
      }
    }

    final newId = DateTime.now().millisecondsSinceEpoch % 10000;
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return ReclamationModel(
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
  }

  Future<void> relancerReclamation(int id) async {}
}
