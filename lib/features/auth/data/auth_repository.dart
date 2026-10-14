import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthRepository(apiClient, storageService);
});

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      final authData = AuthResponse.fromJson(apiResp.data!);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.saveUserInfo(
        id: authData.userId,
        role: authData.role,
        email: authData.email,
        phone: authData.telephone,
        name: '${authData.prenom ?? ''} ${authData.nom ?? ''}'.trim(),
      );
      return authData;
    }
    throw Exception(apiResp.message ?? 'Échec de connexion');
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      final authData = AuthResponse.fromJson(apiResp.data!);
      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.saveUserInfo(
        id: authData.userId,
        role: authData.role,
        email: authData.email,
        phone: authData.telephone,
        name: '${authData.prenom ?? ''} ${authData.nom ?? ''}'.trim(),
      );
      return authData;
    }
    throw Exception(apiResp.message ?? 'Échec d\'inscription');
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  Future<bool> isAuthenticated() async {
    return await _storageService.hasToken();
  }
}
