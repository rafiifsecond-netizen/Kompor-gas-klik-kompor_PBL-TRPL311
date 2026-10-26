import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';
import '../data/dummy/dummy_data.dart';

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
    if (AppConfig.useDummyData) {
      final account = email == 'dewi@example.com' && password == 'password123'
          ? dummyCustomerUser
          : email == 'agus.teknisi@klikkompor.com' && password == 'password123'
              ? dummyTechnicianUser
              : null;
      if (account == null) {
        return ApiResponse<AuthResponseData>(
            success: false, message: 'Email atau password salah.');
      }
      return ApiResponse<AuthResponseData>(
          success: true,
          data: AuthResponseData(
              user: UserModel.fromJson(Map<String, dynamic>.from(account)),
              token: 'dummy-token-${account['id']}'));
    }
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'identifier': email, // API expects 'identifier' (email or phone)
        'password': password,
        'device_name': deviceName,
      },
    );

    return ApiResponse<AuthResponseData>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) =>
          AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
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
    if (AppConfig.useDummyData) {
      if (password.length < 8 ||
          password != passwordConfirmation ||
          email.trim().isEmpty ||
          name.trim().isEmpty) {
        return ApiResponse<AuthResponseData>(
            success: false, message: 'Data registrasi tidak valid.');
      }
      final user = UserModel(
          id: 999,
          name: name,
          email: email,
          phone: phone,
          role: role,
          address: address);
      return ApiResponse<AuthResponseData>(
          success: true,
          data: AuthResponseData(user: user, token: 'dummy-register-token'));
    }
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
      (data) =>
          AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
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
    if (AppConfig.useDummyData) {
      final user = UserModel(
        id: 999,
        name: name ?? dummyCustomerUser['name'] as String,
        email: dummyCustomerUser['email'] as String,
        phone: phone ?? dummyCustomerUser['phone'] as String,
        role: 'customer',
        address: address ?? dummyCustomerUser['address'] as String,
      );
      return ApiResponse<UserModel>(success: true, data: user);
    }
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
    if (AppConfig.useDummyData) {
      return ApiResponse<void>(
          success:
              newPassword.length >= 8 && newPassword == newPasswordConfirmation,
          message: 'Password berhasil diperbarui.');
    }
    final response = await _apiClient.put(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    return ApiResponse<void>.fromJson(
        Map<String, dynamic>.from(response as Map), null);
  }

  /// Invalidate token and logout
  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post(ApiEndpoints.logout);
    return ApiResponse<void>.fromJson(
        Map<String, dynamic>.from(response as Map), null);
  }

  /// Request forgot password reset token
  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    if (AppConfig.useDummyData) {
      return ApiResponse<Map<String, dynamic>>(
          success: email.contains('@'),
          message: 'Token reset dummy tersedia.',
          data: {'reset_token': '123456'});
    }
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => data != null ? Map<String, dynamic>.from(data as Map) : {},
    );
  }

  /// Reset password using token
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (AppConfig.useDummyData) {
      return ApiResponse<void>(
          success:
              newPassword.length >= 8 && newPassword == newPasswordConfirmation,
          message: 'Password berhasil diatur ulang.');
    }
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'token': token,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    return ApiResponse<void>.fromJson(
        Map<String, dynamic>.from(response as Map), null);
  }
}
