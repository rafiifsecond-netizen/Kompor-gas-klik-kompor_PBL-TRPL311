import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';

class AuthResponseData {
  final UserModel user;
  final String token;

  AuthResponseData({required this.user, required this.token});

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      token: json['token'] as String? ?? '',
    );
  }
}

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Login with email and password
  Future<ApiResponse<AuthResponseData>> login({
    required String email,
    required String password,
    String deviceName = 'Flutter Mobile App',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
    );

    return ApiResponse<AuthResponseData>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Register customer or technician account
  Future<ApiResponse<AuthResponseData>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    String role = 'customer',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'address': address,
        'role': role,
      },
    );

    return ApiResponse<AuthResponseData>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Get current authenticated user profile
  Future<ApiResponse<UserModel>> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return ApiResponse<UserModel>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => UserModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Update user profile details
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      },
    );

    return ApiResponse<UserModel>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => UserModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Change user password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    return ApiResponse<void>.fromJson(Map<String, dynamic>.from(response as Map), null);
  }

  /// Invalidate token and logout
  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post(ApiEndpoints.logout);
    return ApiResponse<void>.fromJson(Map<String, dynamic>.from(response as Map), null);
  }
}
