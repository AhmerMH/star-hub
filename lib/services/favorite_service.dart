import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';
import 'package:starhub/widgets/helpers/types/t-series.dart';
import 'package:starhub/widgets/helpers/types/tmovie.dart';

class FavoriteService {
  static const _storage = FlutterSecureStorage();
  
  static const _keyMovies = 'favorite_movies';
  static const _keyLiveTV = 'favorite_livetv';
  static const _keySeries = 'favorite_series';

  static Future<void> saveFavorite({
    TMovie? movie,
    TLiveChannel? liveChannel,
    TSeries? series,
  }) async {
    if (movie != null) {
      final currentMovies = await _getFavoritesByKey(_keyMovies);
      currentMovies.add(jsonEncode(movie.toJson()));
      await _storage.write(key: _keyMovies, value: jsonEncode(currentMovies));
    }
    
    if (liveChannel != null) {
      final currentLiveTV = await _getFavoritesByKey(_keyLiveTV);
      currentLiveTV.add(jsonEncode(liveChannel.toJson()));
      await _storage.write(key: _keyLiveTV, value: jsonEncode(currentLiveTV));
    }
    
    if (series != null) {
      final currentSeries = await _getFavoritesByKey(_keySeries);
      currentSeries.add(jsonEncode(series.toJson()));
      await _storage.write(key: _keySeries, value: jsonEncode(currentSeries));
    }
  }

  static Future<Map<String, List<dynamic>>> getAllFavorites() async {
    final movies = await _getFavoritesByKey(_keyMovies);
    final liveTV = await _getFavoritesByKey(_keyLiveTV);
    final series = await _getFavoritesByKey(_keySeries);

    return {
      'movies': movies.map((m) => TMovie.fromJson(jsonDecode(m))).toList(),
      'livetv': liveTV.map((l) => TLiveChannel.fromJson(jsonDecode(l))).toList(),
      'series': series.map((s) => TSeries.fromJson(jsonDecode(s))).toList(),
    };
  }

  static Future<bool> isFavorited(String id, String type) async {
    String key;
    switch (type) {
      case 'movie':
        key = _keyMovies;
        break;
      case 'livetv':
        key = _keyLiveTV;
        break;
      case 'series':
        key = _keySeries;
        break;
      default:
        return false;
    }

    final items = await _getFavoritesByKey(key);
    return items.any((item) {
      final decoded = jsonDecode(item);
      return decoded['stream_id'].toString() == id;
    });
  }

  static Future<List<String>> _getFavoritesByKey(String key) async {
    final data = await _storage.read(key: key);
    if (data == null) return [];
    return List<String>.from(jsonDecode(data));
  }
}
