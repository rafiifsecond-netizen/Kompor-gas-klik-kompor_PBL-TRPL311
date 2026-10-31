import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class NotificationRepository {
  final ApiClient _api;
  NotificationRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<dynamic> getNotifications() async {
    return _api.get(ApiEndpoints.notifications);
  }

  Future<dynamic> markRead(int id) async {
    return _api.patch(ApiEndpoints.markNotificationRead(id));
  }

  Future<dynamic> markAllRead() async {
    return _api.post(ApiEndpoints.markAllNotificationsRead);
  }
}
