import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsService {
  static const _storage = FlutterSecureStorage();

  static const _keyServer = 'server_url';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyUserInfo = 'user_info';

  static Future<void> saveCredentials({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    await _storage.write(key: _keyServer, value: serverUrl);
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
  }

  static Future<Map<String, String>> getCredentials() async {
    return {
      'serverUrl': await _storage.read(key: _keyServer) ?? '',
      'username': await _storage.read(key: _keyUsername) ?? '',
      'password': await _storage.read(key: _keyPassword) ?? '',
    };
  }

  static Future<void> saveUserInfo(
      {required Map<String, dynamic> userInfo}) async {
    await _storage.write(key: _keyUserInfo, value: jsonEncode(userInfo));
  }

  static Future<Map<String, dynamic>> getUserInfo() async {
    final userInfoStr = await _storage.read(key: _keyUserInfo);
    if (userInfoStr != null) {
      return jsonDecode(userInfoStr);
    }
    return {};
  }
}
