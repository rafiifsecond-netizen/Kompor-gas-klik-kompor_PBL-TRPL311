import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<ApiResponse<AuthResponseData>> login({
    required String email,
    required String password,
    String deviceName = 'Flutter Mobile App',
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'identifier': email,
        'password': password,
        'device_name': deviceName,
      },
    );
    return ApiResponse<AuthResponseData>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<ApiResponse<AuthResponseData>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    String role = 'customer',
    String? bio,
    int? yearsOfExperience,
    List<String>? skills,
    String? ktpNumber,
    XFile? ktpPhoto,
    XFile? applicationLetter,
    XFile? supportingDocument,
  }) async {
    final Map<String, dynamic> payload = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'address': address,
      'role': role,
      if (bio != null) 'bio': bio,
      if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
      if (skills != null) 'skills': skills,
      if (ktpNumber != null) 'ktp_number': ktpNumber,
    };

    dynamic requestData = payload;

    if (ktpPhoto != null || applicationLetter != null || supportingDocument != null) {
      final map = Map<String, dynamic>.from(payload);
      if (ktpPhoto != null) {
        final bytes = await ktpPhoto.readAsBytes();
        map['ktp_photo'] = MultipartFile.fromBytes(
          bytes,
          filename: ktpPhoto.name.isNotEmpty ? ktpPhoto.name : 'foto_ktp.jpg',
        );
      }
      if (applicationLetter != null) {
        final bytes = await applicationLetter.readAsBytes();
        map['application_letter'] = MultipartFile.fromBytes(
          bytes,
          filename: applicationLetter.name.isNotEmpty ? applicationLetter.name : 'surat_lamaran.pdf',
        );
      }
      if (supportingDocument != null) {
        final bytes = await supportingDocument.readAsBytes();
        map['supporting_document'] = MultipartFile.fromBytes(
          bytes,
          filename: supportingDocument.name.isNotEmpty ? supportingDocument.name : 'dokumen_pendukung.pdf',
        );
        map['certificate'] = MultipartFile.fromBytes(
          bytes,
          filename: supportingDocument.name.isNotEmpty ? supportingDocument.name : 'dokumen_pendukung.pdf',
        );
      }
      requestData = FormData.fromMap(map);
    }

    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: requestData,
    );
    return ApiResponse<AuthResponseData>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => AuthResponseData.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<ApiResponse<UserModel>> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return ApiResponse<UserModel>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => UserModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

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
    return ApiResponse<void>.fromJson(
      Map<String, dynamic>.from(response as Map),
      null,
    );
  }

  Future<ApiResponse<void>> logout() async {
    final response = await _apiClient.post(ApiEndpoints.logout);
    return ApiResponse<void>.fromJson(
      Map<String, dynamic>.from(response as Map),
      null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      Map<String, dynamic>.from(response as Map),
      (data) => data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
    );
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
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
      Map<String, dynamic>.from(response as Map),
      null,
    );
  }
}
