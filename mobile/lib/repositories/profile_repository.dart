import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiClient _api;
  ProfileRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Future<Map<String, dynamic>> getCustomerProfile() async {
    final response = await _api.get(ApiEndpoints.me);
    return _profileResponse(response);
  }

  Future<Map<String, dynamic>> getTechnicianProfile() async {
    final response = await _api.get(ApiEndpoints.me);
    return _profileResponse(response);
  }

  Future<UserModel> updateProfile({
    required UserModel currentUser,
    required String name,
    required String phone,
    required String address,
  }) async {
    final response = await _api.put(
      ApiEndpoints.updateProfile,
      data: {'name': name, 'phone': phone, 'address': address},
    );
    final profile = _profileResponse(response);
    return profile['user'] as UserModel;
  }

  Map<String, dynamic> _profileResponse(dynamic response) {
    final data = response is Map ? response['data'] : null;
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    return {
      'user': UserModel.fromJson(
        map['user'] is Map
            ? Map<String, dynamic>.from(map['user'])
            : map,
      ),
      'statistics': map['statistics'] is Map
          ? Map<String, dynamic>.from(map['statistics'])
          : <String, dynamic>{},
    };
  }
}
