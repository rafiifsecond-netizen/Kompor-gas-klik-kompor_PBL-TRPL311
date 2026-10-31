import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class IncomeRepository {
  final ApiClient _api;
  IncomeRepository({ApiClient? api}) : _api = api ?? ApiClient();
  Future<dynamic> getCompletedOrders({int page = 1}) async {
    return _api.get(ApiEndpoints.orders,
        queryParameters: {'status': 'completed', 'page': page});
  }
}
