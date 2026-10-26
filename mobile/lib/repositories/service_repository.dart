import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class ServiceRepository {
  final ApiClient _api;
  ServiceRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getServices() async {
    if (AppConfig.useDummyData) {
      return dummyServices.map(Map<String, dynamic>.from).toList();
    }
    final response = await _api.get(ApiEndpoints.services);
    final rows = response is Map ? response['data'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<Map<String, dynamic>?> getService(int id) async {
    if (AppConfig.useDummyData) {
      for (final service in dummyServices) {
        if (service['id'] == id) return Map<String, dynamic>.from(service);
      }
      return null;
    }
    final response = await _api.get('${ApiEndpoints.services}/$id');
    final data = response is Map ? response['data'] : null;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<String>> getDamageTypes(String serviceName) async {
    if (AppConfig.useDummyData) {
      final text = serviceName.toLowerCase();
      final key = text.contains('regulator')
          ? 'regulator'
          : text.contains('selang')
              ? 'selang'
              : text.contains('instalasi')
                  ? 'instalasi'
                  : 'default';
      return List<String>.from(dummyDamageTypes[key]!);
    }
    return const [];
  }
}
