import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class OrderRepository {
  static final _dummyState = <int, String>{};
  final ApiClient _api;
  OrderRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getOrders() async {
    if (AppConfig.useDummyData) {
      return dummyOrders
          .map((item) => {
                ...item,
                'order_number': '#KP-${item['id']}',
                'customer_id': 1,
                'subtotal': 75000,
                'total_amount': 90000,
                'status': _dummyState[item['id']] ?? item['status'],
                'payment_status': item['status'] == 'paid' ? 'paid' : 'unpaid',
                'items': item['items'] ??
                    [
                      {
                        'service_item_id': item['service_id'] ?? 1,
                        'service_name':
                            item['service_name'] ?? 'Servis Kompor Gas',
                        'quantity': 1,
                        'total_price': 75000,
                      }
                    ],
              })
          .toList();
    }
    final response = await _api.get(ApiEndpoints.orders);
    final data = response is Map ? response['data'] : null;
    final rows = data is Map ? data['data'] : data;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<dynamic> getOrder(int id) async {
    if (AppConfig.useDummyData) {
      final row = (await getOrders())
          .firstWhere((item) => item['id'] == id, orElse: () => {});
      return {'success': row.isNotEmpty, 'data': row};
    }
    return _api.get(ApiEndpoints.orderDetail(id));
  }

  Future<dynamic> createOrder(Map<String, dynamic> data) async {
    if (AppConfig.useDummyData) {
      final id = dummyOrders
              .map((item) => (item['id'] as num?)?.toInt() ?? 0)
              .fold(0, (max, value) => value > max ? value : max) +
          1;
      final order = {
        'id': id,
        'status': 'pending',
        'label': 'Menunggu Pembayaran',
        'order_number': '#KP-$id',
        'customer_id': 101,
        'subtotal': data['subtotal'] ?? 75000,
        'total_amount': data['total_amount'] ?? data['subtotal'] ?? 75000,
        ...data,
      };
      dummyOrders.add(order);
      return {'success': true, 'data': order};
    }
    return _api.post(ApiEndpoints.orders, data: data);
  }

  Future<dynamic> updateStatus(int id, Map<String, dynamic> data) async {
    if (AppConfig.useDummyData) {
      _dummyState[id] = data['status']?.toString() ?? 'pending';
      return {
        'success': true,
        'data': {'id': id, ...data}
      };
    }
    return _api.patch(ApiEndpoints.updateOrderStatus(id), data: data);
  }

  Future<dynamic> updateTechnicianAvailability(bool available) async {
    if (AppConfig.useDummyData) {
      dummyTechnicianUser['is_available'] = available;
      return {
        'success': true,
        'data': {'is_available': available},
      };
    }
    return _api.patch(ApiEndpoints.updateAvailability,
        data: {'is_available': available});
  }

  Future<dynamic> getAdditionalCosts(int id) async {
    if (AppConfig.useDummyData) {
      return {
        'success': true,
        'data': dummyAdditionalCosts[id] ?? <Map<String, dynamic>>[]
      };
    }
    return _api.get(ApiEndpoints.additionalCosts(id));
  }

  Future<dynamic> getServices() async {
    if (AppConfig.useDummyData) return {'success': true, 'data': dummyServices};
    return _api.get(ApiEndpoints.services);
  }

  Future<dynamic> updateServices(int id, List<int> ids) async {
    if (AppConfig.useDummyData) {
      return {
        'success': true,
        'data': {
          'id': id,
          'items': ids
              .map((serviceId) => {'service_item_id': serviceId, 'quantity': 1})
              .toList()
        }
      };
    }
    return _api.patch(
      ApiEndpoints.updateOrderServices(id),
      data: {
        'services':
            ids.map((item) => {'service_item_id': item, 'quantity': 1}).toList()
      },
    );
  }

  Future<dynamic> addAdditionalCost(int id, Map<String, dynamic> data) async {
    if (AppConfig.useDummyData) {
      final costs = dummyAdditionalCosts.putIfAbsent(id, () => []);
      final item = {
        'id': costs.length + 1,
        ...data,
      };
      costs.add(item);
      return {'success': true, 'data': item};
    }
    return _api.post(ApiEndpoints.additionalCosts(id), data: data);
  }
}
