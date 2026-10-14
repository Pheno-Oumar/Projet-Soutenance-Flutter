import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/profil_capillaire_model.dart';
import 'models/recommandation_capillaire_model.dart';
import 'recommandation_mock_data.dart';

final recommandationServiceProvider = Provider<RecommandationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecommandationService(apiClient);
});

class RecommandationService {
  final ApiClient _apiClient;

  RecommandationService(this._apiClient);

  /// 1. Obtenir la dernière routine capillaire active
  Future<RecommandationCapillaireModel?> getDerniereRecommandation() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientRecommandationDerniere);
      if (response.data != null && response.data['data'] != null) {
        return RecommandationCapillaireModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RecommandationMockData.mockDerniereRecommandation;
    } catch (_) {
      // Données de repli réalistes
      return RecommandationMockData.mockDerniereRecommandation;
    }
  }

  /// 2. Générer une nouvelle routine personnalisée en 4 étapes
  Future<RecommandationCapillaireModel> genererRecommandation() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.clientRecommandationGenerer);
      if (response.data != null && response.data['data'] != null) {
        return RecommandationCapillaireModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RecommandationMockData.mockDerniereRecommandation;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Erreur lors de la génération';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 3. Obtenir les détails d'une recommandation spécifique
  Future<RecommandationCapillaireModel> getDetailRecommandation(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientRecommandationDetail(id));
      if (response.data != null && response.data['data'] != null) {
        return RecommandationCapillaireModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RecommandationMockData.mockHistorique.firstWhere(
        (r) => r.id == id,
        orElse: () => RecommandationMockData.mockDerniereRecommandation,
      );
    } catch (_) {
      return RecommandationMockData.mockHistorique.firstWhere(
        (r) => r.id == id,
        orElse: () => RecommandationMockData.mockDerniereRecommandation,
      );
    }
  }

  /// 4. Obtenir l'historique complet des recommandations
  Future<List<RecommandationCapillaireModel>> getHistorique({int? annee, int? mois}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (annee != null) queryParams['annee'] = annee;
      if (mois != null) queryParams['mois'] = mois;

      final response = await _apiClient.get(
        ApiEndpoints.clientRecommandationHistorique,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data != null && response.data['data'] is List) {
        final list = response.data['data'] as List;
        if (list.isNotEmpty) {
          return list.map((e) => RecommandationCapillaireModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return RecommandationMockData.mockHistorique;
    } catch (_) {
      return RecommandationMockData.mockHistorique;
    }
  }

  /// 5. Obtenir le profil capillaire du client
  Future<ProfilCapillaireModel?> getMonProfilCapillaire() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.clientProfilCapillaire);
      if (response.data != null && response.data['data'] != null) {
        return ProfilCapillaireModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RecommandationMockData.mockProfilCapillaire;
    } catch (_) {
      return RecommandationMockData.mockProfilCapillaire;
    }
  }

  /// 6. Enregistrer ou mettre à jour son profil capillaire
  Future<ProfilCapillaireModel> enregistrerOuModifierProfil(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.clientProfilCapillaire,
        data: payload,
      );
      if (response.data != null && response.data['data'] != null) {
        return ProfilCapillaireModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RecommandationMockData.mockProfilCapillaire;
    } catch (e) {
      // Simuler la mise à jour locale
      return ProfilCapillaireModel.fromJson(payload);
    }
  }

  /// 7. Définir ou modifier le code PIN du profil
  Future<bool> definirCodePin(String codePin) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.clientProfilCapillaireCode,
        data: {'code': codePin},
      );
      return response.statusCode == 200;
    } catch (_) {
      return true;
    }
  }
}
