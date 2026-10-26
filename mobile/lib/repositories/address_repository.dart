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

  Future<Map<String, dynamic>> saveDummy(Map<String, dynamic> address) async {
    if (AppConfig.useDummyData) {
      final id = (address['id'] as int?) ??
          (dummyAddresses
                  .map((item) => item['id'] as int)
                  .fold(0, (max, value) => value > max ? value : max) +
              1);
      final saved = {
        ...address,
        'id': id,
        'is_default': address['is_default'] == true,
      };
      final index = dummyAddresses.indexWhere((item) => item['id'] == id);
      if (index == -1) {
        dummyAddresses.add(saved);
      } else {
        dummyAddresses[index] = saved;
      }
      if (saved['is_default'] == true) {
        _setOnlyDefault(id);
      }
      return Map<String, dynamic>.from(saved);
    }
    return address;
  }

  Future<void> deleteDummy(int id) async {
    if (!AppConfig.useDummyData) return;
    dummyAddresses.removeWhere((item) => item['id'] == id);
    if (dummyAddresses.isNotEmpty &&
        !dummyAddresses.any((item) => item['is_default'] == true)) {
      dummyAddresses.first['is_default'] = true;
    }
  }

  Future<void> setDefaultDummy(int id) async {
    if (!AppConfig.useDummyData) return;
    _setOnlyDefault(id);
  }

  void _setOnlyDefault(int id) {
    for (final address in dummyAddresses) {
      address['is_default'] = address['id'] == id;
    }
  }
}
