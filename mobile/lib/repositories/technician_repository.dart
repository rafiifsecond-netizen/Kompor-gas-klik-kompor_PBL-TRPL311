import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class TechnicianRepository {
  final ApiClient _api;
  TechnicianRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getTechnicians() async {
    final response = await _api.get(ApiEndpoints.technicians);
    final data = response is Map ? response['data'] : null;
    final rows = data is Map ? data['data'] : data;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<Map<String, dynamic>?> getTechnicianDetail(int id) async {
    final response = await _api.get('${ApiEndpoints.technicians}/$id');
    final data = response is Map ? response['data'] : null;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
