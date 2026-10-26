import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../data/dummy/dummy_data.dart';

class IncomeRepository {
  final ApiClient _api;
  IncomeRepository({ApiClient? api}) : _api = api ?? ApiClient();
  Future<dynamic> getCompletedOrders() async {
    if (AppConfig.useDummyData) {
      return {
        'success': true,
        'data': {
          'data': dummyOrders
              .where((item) => item['status'] == 'completed')
              .map((item) => {
                    ...item,
                    'order_number': '#KP-${item['id']}',
                    'customer_id': 1,
                    'subtotal': 150000,
                    'total_amount': 165000,
                    'payment_status': 'paid',
                    'booking_date': '2026-10-27',
                  })
              .toList(),
        },
      };
    }
    return _api
        .get(ApiEndpoints.orders, queryParameters: {'status': 'completed'});
  }
}
