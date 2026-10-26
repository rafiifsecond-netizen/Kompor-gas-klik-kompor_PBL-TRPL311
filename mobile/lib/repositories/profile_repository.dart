import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiClient _api;
  ProfileRepository({ApiClient? api}) : _api = api ?? ApiClient();

  Map<String, dynamic> get customerProfile => {
        'user': UserModel.fromJson(dummyCustomerUser),
        'statistics': {'total_orders': 6, 'completed_orders': 3, 'reviews': 2},
      };

  Map<String, dynamic> get technicianProfile => {
        'user': UserModel.fromJson({
          ...dummyTechnicianUser,
          'technician_profile': {
            'id': 201,
            'rating_average': 4.9,
            'total_reviews': 18,
            'total_completed_orders': 24,
            'is_verified': true,
            'is_available': true,
            'specialization': 'Kompor gas & regulator',
          },
        }),
        'statistics': {
          'chat_response_rate': '98%',
          'status_account': 'Terverifikasi',
        },
      };

  Future<Map<String, dynamic>> getCustomerProfile() async {
    if (AppConfig.useDummyData) {
      return customerProfile;
    }
    final response = await _api.get(ApiEndpoints.me);
    return _profileResponse(response);
  }

  Future<Map<String, dynamic>> getTechnicianProfile() async {
    if (AppConfig.useDummyData) {
      return technicianProfile;
    }
    final response = await _api.get(ApiEndpoints.me);
    return _profileResponse(response);
  }

  Future<UserModel> updateProfile({
    required UserModel currentUser,
    required String name,
    required String phone,
    required String address,
  }) async {
    if (AppConfig.useDummyData) {
      final target = currentUser.isTechnician ? dummyTechnicianUser : dummyCustomerUser;
      target['name'] = name;
      target['phone'] = phone;
      target['address'] = address;
      return UserModel.fromJson({
        ...target,
        if (currentUser.isTechnician)
          'technician_profile': currentUser.technicianProfile?.toJson(),
      });
    }
    final response = await _api.patch(ApiEndpoints.updateProfile, data: {
      'name': name,
      'phone': phone,
      'address': address,
    });
    final profile = _profileResponse(response);
    return profile['user'] as UserModel;
  }

  Map<String, dynamic> _profileResponse(dynamic response) {
    final data = response is Map ? response['data'] : null;
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    return {
      'user': UserModel.fromJson(map['user'] is Map ? Map<String, dynamic>.from(map['user']) : map),
      'statistics': map['statistics'] is Map
          ? Map<String, dynamic>.from(map['statistics'])
          : <String, dynamic>{},
    };
  }
}
