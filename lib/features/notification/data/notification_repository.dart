import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository(this._apiClient);

  Future<PageResponse<NotificationModel>> listerMesNotifications({
    int page = 0,
    int size = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.clientNotifications,
      queryParameters: {'page': page, 'size': size},
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return PageResponse<NotificationModel>.fromJson(
        apiResp.data!,
        (item) => NotificationModel.fromJson(item),
      );
    }
    return const PageResponse(content: [], totalElements: 0, totalPages: 0, size: 15, number: 0);
  }

  Future<NotificationCountModel> compterNotifications() async {
    final response = await _apiClient.get(
      ApiEndpoints.clientNotificationsNonLuesCount,
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return NotificationCountModel.fromJson(apiResp.data!);
    }
    return const NotificationCountModel(total: 0, nonLues: 0);
  }

  Future<NotificationModel> marquerCommeLu(int id) async {
    final response = await _apiClient.patch(
      ApiEndpoints.clientNotificationLire(id),
    );

    final apiResp = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );

    if (apiResp.data != null) {
      return NotificationModel.fromJson(apiResp.data!);
    }
    throw Exception(apiResp.message ?? 'Échec lors de la lecture de la notification');
  }

  Future<void> toutMarquerCommeLu() async {
    await _apiClient.patch(ApiEndpoints.clientNotificationsToutLire);
  }

  Future<void> supprimerNotification(int id) async {
    await _apiClient.delete(ApiEndpoints.clientNotificationSupprimer(id));
  }
}
