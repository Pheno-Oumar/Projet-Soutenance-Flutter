import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/salon_model.dart';

final salonRepositoryProvider = Provider<SalonRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalonRepository(apiClient);
});

class SalonRepository {
  final ApiClient _apiClient;

  SalonRepository(this._apiClient);

  Future<PageResponse<SalonModel>> listerSalons({
    int page = 0,
    int size = 15,
    String? query,
  }) async {
    final endpoint = query != null && query.isNotEmpty
        ? ApiEndpoints.salonSearch
        : ApiEndpoints.salons;

    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return PageResponse<SalonModel>.fromJson(
        apiResp.data!,
        (item) => SalonModel.fromJson(item),
      );
    }
    return const PageResponse(content: [], totalElements: 0, totalPages: 0, size: 15, number: 0);
  }

  Future<SalonModel> getSalonBySlug(String slug) async {
    final response = await _apiClient.get(ApiEndpoints.salonDetail(slug));

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return SalonModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Salon introuvable');
  }
}
