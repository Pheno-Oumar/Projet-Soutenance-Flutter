import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/rgpd_models.dart';

final rgpdRepositoryProvider = Provider<RgpdRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RgpdRepository(apiClient);
});

class RgpdRepository {
  final ApiClient _apiClient;

  RgpdRepository(this._apiClient);

  Future<EligibiliteSuppressionModel> verifierEligibiliteSuppression() async {
    final response = await _apiClient.get(ApiEndpoints.clientRgpdEligibiliteSuppression);
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw;
      if (data is Map<String, dynamic>) {
        return EligibiliteSuppressionModel.fromJson(data);
      }
    }
    throw Exception('Impossible de vérifier l\'éligibilité à la suppression.');
  }

  Future<DemandeSuppressionModel> demanderSuppression({String? motif}) async {
    final response = await _apiClient.post(
      ApiEndpoints.clientRgpdSuppression,
      data: motif != null && motif.trim().isNotEmpty ? {'motif': motif.trim()} : null,
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw;
      if (data is Map<String, dynamic>) {
        return DemandeSuppressionModel.fromJson(data);
      }
    }
    throw Exception('Échec de l\'envoi de la demande de suppression.');
  }

  Future<List<DemandeSuppressionModel>> consulterSuiviSuppression() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientRgpdSuivi);
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'] ?? raw;
        if (data is List) {
          return data
              .map((item) => DemandeSuppressionModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<DemandeExportModel> demanderExport(String format) async {
    final response = await _apiClient.post(
      ApiEndpoints.clientRgpdExport,
      data: {'format': format},
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw;
      if (data is Map<String, dynamic>) {
        return DemandeExportModel.fromJson(data);
      }
    }
    throw Exception('Impossible de générer l\'exportation de données.');
  }

  Future<List<DemandeExportModel>> consulterMesArchives() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientRgpdArchives);
      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'] ?? raw;
        if (data is List) {
          return data
              .map((item) => DemandeExportModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
