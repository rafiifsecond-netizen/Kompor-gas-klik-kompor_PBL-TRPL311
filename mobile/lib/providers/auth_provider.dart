import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/storage_service.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  Map<String, dynamic>? _validationErrors;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool get isLoading => _status == AuthStatus.authenticating;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isTechnician => _user?.isTechnician ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Helper to get single validation message
  String? getFieldError(String field) {
    if (_validationErrors == null || !_validationErrors!.containsKey(field)) return null;
    final val = _validationErrors![field];
    if (val is List && val.isNotEmpty) return val.first.toString();
    if (val is String) return val;
    return null;
  }

  /// Initialize and check stored session
  Future<void> init() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final cachedToken = _authRepository.getCachedToken();
      if (cachedToken == null || cachedToken.isEmpty) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        notifyListeners();
        return;
      }

      // Check user cached or fetch fresh
      final user = await _authRepository.fetchCurrentUser();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _validationErrors = e.errors;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Register customer or technician
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    String role = 'customer',
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    try {
      _user = await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        address: address,
        role: role,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      _validationErrors = e.errors;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update Profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    try {
      _user = await _authRepository.updateProfile(
        name: name,
        phone: phone,
        address: address,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.authenticated; // Keep authenticated, show error banner
      _errorMessage = e.message;
      _validationErrors = e.errors;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.authenticated;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }

  /// Clear any error messages
  void clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }

  /// Change custom API IP
  Future<void> setCustomBaseUrl(String url) async {
    await StorageService.saveCustomBaseUrl(url);
    ApiEndpoints.setBaseUrl(url);
    notifyListeners();
  }
}
