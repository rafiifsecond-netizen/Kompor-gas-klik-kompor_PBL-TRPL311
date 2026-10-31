import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class ServiceRepository {
  final ApiClient _api;
  ServiceRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getServices() async {
    final response = await _api.get(ApiEndpoints.services);
    final rows = response is Map ? response['data'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<Map<String, dynamic>?> getService(int id) async {
    final response = await _api.get('${ApiEndpoints.services}/$id');
    final data = response is Map ? response['data'] : null;
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Backend has no dedicated damage-type table yet, so the service catalog is
  /// used as the list of selectable problem types. Returning an empty list
  /// would block the booking form, so we always fall back to a sane default.
  Future<List<String>> getDamageTypes(String serviceName) async {
    try {
      final rows = await getServices();
      final names = rows
          .map((row) => row['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
      if (names.isNotEmpty) return names;
    } catch (_) {}
    return const [
      'Kompor tidak menyala',
      'Api kompor kecil / tidak stabil',
      'Bocor gas',
      'Pemantik otomatis rusak',
      'Kompor perlu dibersihkan / servis rutin',
      'Lainnya',
    ];
  }
}
