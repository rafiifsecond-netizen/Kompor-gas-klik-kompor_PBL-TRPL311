import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class AddressRepository {
  final ApiClient _api;
  AddressRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getAddresses() async {
    if (AppConfig.useDummyData) {
      return dummyAddresses.map(Map<String, dynamic>.from).toList();
    }
    final response = await _api.get(ApiEndpoints.addresses);
    final rows = response is Map ? response['data'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<Map<String, dynamic>> saveDummy(Map<String, dynamic> address) async =>
      address;

  Future<void> deleteDummy(int id) async {}

  Future<void> setDefaultDummy(int id) async {}
}
