import 'package:starhub/services/iptv_service.dart';

class TMovie {
  final int num;
  final String name;
  final String streamType;
  final int streamId;
  final String streamIcon;
  final double rating;
  final double rating5based;
  final String added;
  final String categoryId;
  final String containerExtension;
  final String customSid;
  final String directSource;
  String? movieStreamUrl;

  TMovie({
    required this.num,
    required this.name,
    required this.streamType,
    required this.streamId,
    required this.streamIcon,
    required this.rating,
    required this.rating5based,
    required this.added,
    required this.categoryId,
    required this.containerExtension,
    required this.customSid,
    required this.directSource,
  });

  factory TMovie.fromJson(Map<String, dynamic> json) {
    return TMovie(
      num: json['num'] ?? 0,
      name: json['name'] ?? '',
      streamType: json['stream_type'] ?? '',
      streamId: json['stream_id'] ?? 0,
      streamIcon: json['stream_icon'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      rating5based: json['rating_5based']?.toDouble() ?? 0.0,
      added: json['added'] ?? '',
      categoryId: json['category_id'] ?? '',
      containerExtension: json['container_extension'] ?? '',
      customSid: json['custom_sid'] ?? '',
      directSource: json['direct_source'] ?? '',
    );
  }

  Future<String> get streamUrl async {
    if (movieStreamUrl != null) return movieStreamUrl!;

    final credentials = await IptvService.getSavedCredentials();
    movieStreamUrl =
        '${credentials['serverUrl']}/movie?username=${credentials['username']}&password=${credentials['password']}&stream_id=$streamId';
    return movieStreamUrl!;
  }

  Map<String, dynamic> toJson() {
    return {
      'num': num,
      'name': name,
      'stream_type': streamType,
      'stream_id': streamId,
      'stream_icon': streamIcon,
      'rating': rating,
      'rating_5based': rating5based,
      'added': added,
      'category_id': categoryId,
      'container_extension': containerExtension,
      'custom_sid': customSid,
      'direct_source': directSource,
    };
  }
}

class TMovieDetail {
  final String name;
  final String rating;
  final String releaseDate;
  final String genre;
  final String cast;
  final String plot;
  final String youtubeTrailer;
  final String tmdbUrl;
  final int streamId;
  final String added;
  final String categoryId;
  final String containerExtension;
  final String customSid;
  final String directSource;
  final String director;
  final String cover;
  final String duration;
  final String country;

  TMovieDetail({
    required this.name,
    required this.rating,
    required this.releaseDate,
    required this.genre,
    required this.cast,
    required this.plot,
    required this.youtubeTrailer,
    required this.tmdbUrl,
    required this.streamId,
    required this.added,
    required this.categoryId,
    required this.containerExtension,
    required this.customSid,
    required this.directSource,
    required this.director,
    required this.cover,
    required this.duration,
    required this.country,
  });

  factory TMovieDetail.fromJson(Map<String, dynamic> json) {
    final info = json['info'];
    final movieData = json['movie_data'];

    return TMovieDetail(
      name: info['name'] ?? '',
      rating: info['rating'] ?? '',
      releaseDate: info['releasedate'] ?? '',
      genre: info['genre'] ?? '',
      cast: info['cast'] ?? '',
      plot: info['plot'] ?? '',
      youtubeTrailer: info['youtube_trailer'] ?? '',
      cover: info['cover_big'] ?? '',
      duration: info['duration'] ?? '',
      country: info['country'] ?? '',
      director: info['director'] ?? '',
      tmdbUrl: info['kinopoisk_url'] ?? '',
      streamId: movieData['stream_id'] ?? 0,
      added: movieData['added'] ?? '',
      categoryId: movieData['category_id'] ?? '',
      containerExtension: movieData['container_extension'] ?? '',
      customSid: movieData['custom_sid'] ?? '',
      directSource: movieData['direct_source'] ?? '',
    );
  }
}
