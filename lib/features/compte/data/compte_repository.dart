import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/compte_model.dart';

final compteRepositoryProvider = Provider<CompteRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompteRepository(apiClient);
});

class CompteRepository {
  final ApiClient _apiClient;

  CompteRepository(this._apiClient);

  Future<CompteModel> getCompte() async {
    final response = await _apiClient.get(ApiEndpoints.clientCompte);

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return CompteModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Profil introuvable');
  }

  Future<CompteModel> updateCompte({
    required String nom,
    required String prenom,
    String? email,
    String? telephone,
    String? pays,
    String? dateNaissance,
  }) async {
    final payload = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
    };
    if (email != null) payload['email'] = email;
    if (telephone != null) payload['telephone'] = telephone;
    if (pays != null) payload['pays'] = pays;
    if (dateNaissance != null) payload['dateNaissance'] = dateNaissance;

    final response = await _apiClient.put(
      ApiEndpoints.clientCompte,
      data: payload,
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return CompteModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Échec de mise à jour du profil');
  }

  Future<void> changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.clientChangementMotDePasse,
      data: {
        'ancienMotDePasse': ancienMotDePasse,
        'nouveauMotDePasse': nouveauMotDePasse,
      },
    );
  }
}
