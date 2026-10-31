import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class AddressRepository {
  final ApiClient _api;
  AddressRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final response = await _api.get(ApiEndpoints.addresses);
    final rows = response is Map ? response['data'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<Map<String, dynamic>> save(
    Map<String, dynamic> address, {
    int? id,
  }) async {
    final response = id == null
        ? await _api.post(ApiEndpoints.addresses, data: address)
        : await _api.put(ApiEndpoints.addressDetail(id), data: address);
    final data = response is Map ? response['data'] : null;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<void> delete(int id) async {
    await _api.delete(ApiEndpoints.addressDetail(id));
  }

  Future<void> setDefault(int id) async {
    await _api.patch(ApiEndpoints.setDefaultAddress(id));
  }
}
