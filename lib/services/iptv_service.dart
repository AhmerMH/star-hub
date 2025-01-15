import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:starhub/services/credentials_service.dart';

class IptvService {
  static const serverUrl = 'http://webhop.xyz:8080';
  static final Dio _dio = Dio();
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 15);
  static DateTime? _lastFetchTime;

  static String? username;
  static String? password;

  static Future<void> loadCredentials() async {
    final credentials = await CredentialsService.getCredentials();
    // serverUrl = credentials['serverUrl'];
    username = credentials['username'];
    password = credentials['password'];
  }

  static Future<dynamic> fetchMovies() async {
    // Check if cache exists and is still valid
    if (_cache['movies'] != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return _cache['movies'];
      }
    }

    // If no cache or expired, fetch fresh data
    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_vod_streams',
          'order': 'top',
        },
      );
      
      // Update cache and timestamp
      _cache['movies'] = response.data;
      _lastFetchTime = DateTime.now();
      
      return response.data;
    } catch (e) {
      print('Error fetching movies: $e');
      return Future.value([]);
    }
  }
  static Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
        },
      );

      if (response.data["user_info"]["auth"] == 0) {
        return false;
      }

      if (response.statusCode == 200 && response.data["user_info"]["auth"] == 1) {
        await CredentialsService.saveCredentials(
          serverUrl: serverUrl,
          username: username,
          password: password,
        );

        final userInfo = {
          'username': response.data["user_info"]["username"],
          'status': response.data["user_info"]["status"],
          'expirationDate': response.data["user_info"]["exp_date"],
          'isTrialAccount': response.data["user_info"]["is_trial"],
          'activeConnections': response.data["user_info"]["active_cons"],
          'maxConnections': response.data["user_info"]["max_connections"],
          'allowedFormat': response.data["user_info"]["allowed_output_formats"],
          'createdAt': response.data["user_info"]["created_at"],
        };

        await CredentialsService.saveUserInfo(
          userInfo: userInfo,
        );

        final cred = await CredentialsService.getUserInfo();
        print(cred);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<void> logout() async {
    await CredentialsService.saveCredentials(
      serverUrl: '',
      username: '',
      password: '',
    );
  }

  static Future<dynamic> getSavedCredentials() async {
    return await CredentialsService.getCredentials();
  }
}
