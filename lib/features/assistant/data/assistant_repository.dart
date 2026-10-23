import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/assistant_models.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AssistantRepository(apiClient);
});

class AssistantRepository {
  final ApiClient _apiClient;

  AssistantRepository(this._apiClient);

  Future<AssistantChatResponse> sendMessage({
    required String message,
    required String sessionId,
    String? slugSalon,
    String pageCourante = 'ACCUEIL',
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{
      'message': message,
      'prompt': message,
      'sessionId': sessionId,
      'pageCourante': pageCourante,
      if (slugSalon != null && slugSalon.isNotEmpty) 'slugSalon': slugSalon,
      'latitude': ?latitude,
      'longitude': ?longitude,
    };

    final response = await _apiClient.post(
      ApiEndpoints.assistantChat,
      data: payload,
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return AssistantChatResponse.fromJson(apiResp.data!);
    }

    return AssistantChatResponse(
      texte: apiResp.message ?? 'Je suis à votre écoute pour vos besoins capillaires !',
    );
  }
}
