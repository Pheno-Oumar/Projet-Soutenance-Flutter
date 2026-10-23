import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/commande_model.dart';

final commandeRepositoryProvider = Provider<CommandeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CommandeRepository(apiClient);
});

class CommandeRepository {
  final ApiClient _apiClient;

  CommandeRepository(this._apiClient);

  List<CommandeModel> getMockCommandesSync({StatutCommande? filtreStatut}) {
    return const [];
  }

  Future<List<CommandeModel>> getCommandes({StatutCommande? filtreStatut}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (filtreStatut != null) {
        queryParams['statut'] = filtreStatut.code;
      }
      final response = await _apiClient.get(
        ApiEndpoints.clientCommandes,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.data != null && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((e) => CommandeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<CommandeModel> getCommandeDetail(int id) async {
    final response = await _apiClient.get(ApiEndpoints.clientCommandeDetail(id));
    if (response.data != null && response.data['data'] != null) {
      return CommandeModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Détail de la commande introuvable');
  }

  Future<bool> annulerCommande(int id) async {
    try {
      final response = await _apiClient.post('${ApiEndpoints.clientCommandes}/$id/annuler');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
