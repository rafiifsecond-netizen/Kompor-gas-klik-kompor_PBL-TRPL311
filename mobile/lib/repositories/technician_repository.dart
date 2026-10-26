import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class TechnicianRepository {
  final ApiClient _api;
  TechnicianRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getTechnicians() async {
    if (AppConfig.useDummyData) {
      return dummyTechnicians.map(Map<String, dynamic>.from).toList();
    }
    final response = await _api.get(ApiEndpoints.technicians);
    final data = response is Map ? response['data'] : null;
    final rows = data is Map ? data['data'] : data;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }
}
