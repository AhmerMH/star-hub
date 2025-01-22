import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:starhub/services/credentials_service.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';
import 'package:starhub/widgets/helpers/types/t-series.dart';
import 'package:starhub/widgets/helpers/types/tmovie.dart';

enum CategoryType {
  livetv,
  series,
  movies,
}

class TCategory {
  String id;
  String name;

  TCategory({
    required this.id,
    required this.name,
  });

  factory TCategory.fromJson(Map<String, dynamic> json) => TCategory(
        id: json['category_id'] ?? '',
        name: json['category_name'] ?? '',
      );
}

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

  static Future<List<TMovie>> fetchMovies() async {
    // Check if cache exists and is still valid
    if (_cache['movies'] != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return parseMoviesToTMovie(_cache['movies']);
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

      return parseMoviesToTMovie(response.data);
    } catch (e) {
      _cache['movies'] = null;
      debugPrint('Error fetching movies: $e');
      return Future.value([]);
    }
  }

  static List<TMovie> parseMoviesToTMovie(List<dynamic> movies) {
    return movies.map((movie) => TMovie.fromJson(movie)).toList();
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

      if (response.statusCode == 200 &&
          response.data["user_info"]["auth"] == 1) {
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

  static Future<List<TCategory>> fetchCategories(
      {required CategoryType type}) async {
    final String cacheKey = 'categories_$type';
    final action = parseAction(type);

    // Check if cache exists and is still valid
    if (_cache[cacheKey] != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return parseCategoriesToTCategory(_cache[cacheKey]);
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
          'action': action,
        },
      );

      // Update cache and timestamp
      _cache[cacheKey] = response.data;
      _lastFetchTime = DateTime.now();

      return parseCategoriesToTCategory(_cache[cacheKey]);
    } catch (e) {
      _cache[cacheKey] = null;
      debugPrint('Error fetching $type categories: $e');
      return Future.value([]);
    }
  }

  static List<TCategory> parseCategoriesToTCategory(List<dynamic> categories) {
    return categories.fold<List<TCategory>>([], (list, category) {
      final cat = TCategory.fromJson(category);
      if (cat.id.isNotEmpty && cat.name.isNotEmpty) {
        list.add(cat);
      }
      return list;
    });
  }

  static String parseAction(CategoryType type) {
    switch (type) {
      case CategoryType.livetv:
        return 'get_live_categories';
      case CategoryType.series:
        return 'get_series_categories';
      case CategoryType.movies:
        return 'get_vod_categories';
    }
  }

  static Future<TMovieDetail?> getMovieDetails(int id) async {
    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_vod_info',
          'vod_id': id,
        },
      );

      return TMovieDetail.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
      return Future.value(null);
    }
  }

  static Future<TSeriesDetails?> getSeriesDetails(int id) async {
    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_series_info',
          'series_id': id,
        },
      );

      return TSeriesDetails.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching series details: $e');
      return Future.value(null);
    }
  }

  static Future<List<TLiveChannel>> fetchLiveChannels() async {
    // Check cache first
    if (_cache['live_channels'] != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return parseLiveChannelsToTLiveChannel(_cache['live_channels']);
      }
    }

    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_live_streams',
        },
      );

      // Update cache and timestamp
      _cache['live_channels'] = response.data;
      _lastFetchTime = DateTime.now();

      return parseLiveChannelsToTLiveChannel(response.data);
    } catch (e) {
      _cache['live_channels'] = null;
      debugPrint('Error fetching live channels: $e');
      return Future.value([]);
    }
  }

  static List<TLiveChannel> parseLiveChannelsToTLiveChannel(
      List<dynamic> channels) {
    return channels.map((channel) => TLiveChannel.fromJson(channel)).toList();
  }

  static Future<List<TSeries>> fetchSeries() async {
    // Check cache first
    if (_cache['series'] != null && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return parseSeriesToTSeries(_cache['series']);
      }
    }

    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_series',
        },
      );

      // Update cache and timestamp
      _cache['series'] = response.data;
      _lastFetchTime = DateTime.now();

      return parseSeriesToTSeries(response.data);
    } catch (e) {
      _cache['series'] = null;
      debugPrint('Error fetching series: $e');
      return [];
    }
  }

  static List<TSeries> parseSeriesToTSeries(List<dynamic> series) {
    return series.map((series) => TSeries.fromJson(series)).toList();
  }

  static Future<Map<String, dynamic>> getEpgDetails(String epgChannelId, String categoryId) async {
    try {
      await loadCredentials();
      final response = await _dio.get(
        '$serverUrl/player_api.php',
        queryParameters: {
          'username': username,
          'password': password,
          'action': 'get_simple_data_table',
          'stream_id': epgChannelId,
          'category_id': categoryId
        },
      );

      final test = jsonEncode(response.data);
      return response.data;
    } catch (e) {
      debugPrint('Error fetching EPG details: $e');
      return {};
    }
  }
}
