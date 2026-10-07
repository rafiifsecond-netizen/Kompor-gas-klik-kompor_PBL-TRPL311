import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Auto-detect: web/windows/macos/linux = localhost, android = 10.0.2.2, iOS = localhost
  static String baseUrl = _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  // Allows switching host IP easily for physical device testing
  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  // Authentication
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get me => '$baseUrl/auth/me';
  static String get updateProfile => '$baseUrl/auth/profile';
  static String get changePassword => '$baseUrl/auth/password';

  // Catalog & Services
  static String get services => '$baseUrl/services';
  static String get categories => '$baseUrl/categories';

  // Technicians
  static String get technicians => '$baseUrl/technicians';
  static String technicianDetail(int id) => '$baseUrl/technicians/$id';
  static String get updateAvailability => '$baseUrl/technician/availability';
  static String get updateLocation => '$baseUrl/technician/location';

  // Addresses
  static String get addresses => '$baseUrl/addresses';
  static String addressDetail(int id) => '$baseUrl/addresses/$id';
  static String setDefaultAddress(int id) => '$baseUrl/addresses/$id/default';

  // Orders
  static String get orders => '$baseUrl/orders';
  static String orderDetail(int id) => '$baseUrl/orders/$id';
  static String updateOrderStatus(int id) => '$baseUrl/orders/$id/status';
  static String payOrder(int id) => '$baseUrl/orders/$id/pay';
  static String rescheduleOrder(int id) => '$baseUrl/orders/$id/reschedule';
  static String reviewOrder(int id) => '$baseUrl/orders/$id/review';

  // Order Chat
  static String orderChat(int orderId) => '$baseUrl/orders/$orderId/chat';
  static String sendChatMessage(int orderId) => '$baseUrl/orders/$orderId/chat/messages';
  static String markChatRead(int orderId) => '$baseUrl/orders/$orderId/chat/read';

  // Additional Costs
  static String additionalCosts(int orderId) => '$baseUrl/orders/$orderId/additional-costs';
  static String approveAdditionalCost(int orderId, int costId) =>
      '$baseUrl/orders/$orderId/additional-costs/$costId/approve';
  static String rejectAdditionalCost(int orderId, int costId) =>
      '$baseUrl/orders/$orderId/additional-costs/$costId/reject';

  // Notifications
  static String get notifications => '$baseUrl/notifications';
  static String get unreadNotificationsCount => '$baseUrl/notifications/unread-count';
  static String markNotificationRead(int id) => '$baseUrl/notifications/$id/read';
  static String get markAllNotificationsRead => '$baseUrl/notifications/read-all';
}
