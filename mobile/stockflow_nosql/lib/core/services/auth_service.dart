import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants.dart';
import '../models/auth_response.dart';
import '../models/user_profile.dart';

class AuthService {
  final FlutterSecureStorage _storage;

  AuthService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession(AuthResponse response) async {
    await _storage.write(key: AppConstants.tokenKey, value: response.accessToken);
    await _storage.write(key: AppConstants.expiresKey, value: response.expiresAtUtc);
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(response.user.toJson()),
    );
  }

  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  Future<UserProfile?> getUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) {
      return null;
    }

    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
    await _storage.delete(key: AppConstants.expiresKey);
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
