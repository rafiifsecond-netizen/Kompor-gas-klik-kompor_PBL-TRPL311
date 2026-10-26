import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class NotificationRepository {
  final ApiClient _api;
  NotificationRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<dynamic> getNotifications() async {
    if (AppConfig.useDummyData) {
      return {
        'data': {'data': dummyNotifications}
      };
    }
    return _api.get(ApiEndpoints.notifications);
  }

  Future<dynamic> markRead(int id) async {
    if (AppConfig.useDummyData) {
      final index = dummyNotifications
          .indexWhere((notification) => notification['id'] == id);
      if (index != -1) {
        dummyNotifications[index] = {
          ...dummyNotifications[index],
          'is_read': true,
        };
      }
      return {'success': true};
    }
    return _api.patch(ApiEndpoints.markNotificationRead(id));
  }

  Future<dynamic> markAllRead() async {
    if (AppConfig.useDummyData) {
      for (var index = 0; index < dummyNotifications.length; index++) {
        dummyNotifications[index] = {
          ...dummyNotifications[index],
          'is_read': true,
        };
      }
      return {'success': true};
    }
    return _api.post(ApiEndpoints.markAllNotificationsRead);
  }
}
