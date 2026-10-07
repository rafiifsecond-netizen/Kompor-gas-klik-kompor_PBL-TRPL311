import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService}) : _authService = authService ?? AuthService();

  /// Retrieve locally cached user
  UserModel? getCachedUser() {
    return StorageService.getUser();
  }

  /// Retrieve locally cached auth token
  String? getCachedToken() {
    return StorageService.getToken();
  }

  /// Authenticate and persist session
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(email: email, password: password);
    if (response.data == null) {
      throw Exception(response.message ?? 'Gagal melakukan login.');
    }

    final authData = response.data!;
    await StorageService.saveToken(authData.token);
    await StorageService.saveUser(authData.user);

    return authData.user;
  }

  /// Register and persist session
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    String role = 'customer',
  }) async {
    final response = await _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: address,
      role: role,
    );

    if (response.data == null) {
      throw Exception(response.message ?? 'Gagal melakukan registrasi.');
    }

    final authData = response.data!;
    await StorageService.saveToken(authData.token);
    await StorageService.saveUser(authData.user);

    return authData.user;
  }

  /// Verify and fetch fresh user profile from backend
  Future<UserModel?> fetchCurrentUser() async {
    final token = StorageService.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _authService.getMe();
      if (response.data != null) {
        await StorageService.saveUser(response.data!);
        return response.data;
      }
    } catch (_) {
      // If token expired or network unavailable, fall back to cached user
    }
    return StorageService.getUser();
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await _authService.updateProfile(
      name: name,
      phone: phone,
      address: address,
    );
    if (response.data != null) {
      await StorageService.saveUser(response.data!);
      return response.data!;
    }
    throw Exception(response.message ?? 'Gagal memperbarui profil.');
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  /// Logout and clear persistent storage
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Even if network fails, always clear local session
    } finally {
      await StorageService.clearSession();
    }
  }
}
