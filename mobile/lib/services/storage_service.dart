import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Auth Token
  static Future<bool> saveToken(String token) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(AppConstants.keyToken, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.keyToken);
  }

  static Future<bool> removeToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.remove(AppConstants.keyToken);
  }

  // Cached User Model
  static Future<bool> saveUser(UserModel user) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final raw = _prefs?.getString(AppConstants.keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> removeUser() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.remove(AppConstants.keyUser);
  }

  // Custom Base URL (if user wants to connect to a different LAN IP)
  static Future<bool> saveCustomBaseUrl(String url) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.setString(AppConstants.keyBaseUrl, url);
  }

  static String? getCustomBaseUrl() {
    return _prefs?.getString(AppConstants.keyBaseUrl);
  }

  // Clear all session data
  static Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}
