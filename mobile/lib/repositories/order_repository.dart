import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class OrderRepository {
  final ApiClient _api;
  OrderRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _api.get(ApiEndpoints.orders);
    final data = response is Map ? response['data'] : null;
    final rows = data is Map ? data['data'] : data;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<dynamic> getOrder(int id) async {
    return _api.get(ApiEndpoints.orderDetail(id));
  }

  Future<dynamic> createOrder(Map<String, dynamic> data) async {
    return _api.post(ApiEndpoints.orders, data: data);
  }

  Future<dynamic> updateStatus(int id, Map<String, dynamic> data) async {
    return _api.patch(ApiEndpoints.updateOrderStatus(id), data: data);
  }

  Future<dynamic> updateTechnicianAvailability(bool available) async {
    return _api.patch(ApiEndpoints.updateAvailability,
        data: {'is_available': available});
  }

  Future<dynamic> updateTechnicianLocation(double latitude, double longitude) async {
    return _api.patch(ApiEndpoints.updateLocation,
        data: {'latitude': latitude, 'longitude': longitude});
  }

  Future<dynamic> getAdditionalCosts(int id) async {
    return _api.get(ApiEndpoints.additionalCosts(id));
  }

  Future<dynamic> getServices() async {
    return _api.get(ApiEndpoints.services);
  }

  Future<dynamic> updateServices(int id, List<int> ids) async {
    return _api.patch(
      ApiEndpoints.updateOrderServices(id),
      data: {
        'services':
            ids.map((item) => {'service_item_id': item, 'quantity': 1}).toList()
      },
    );
  }

  Future<dynamic> addAdditionalCost(int id, Map<String, dynamic> data) async {
    return _api.post(ApiEndpoints.additionalCosts(id), data: data);
  }
}
