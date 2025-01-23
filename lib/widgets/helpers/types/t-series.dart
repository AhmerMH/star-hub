import 'package:starhub/services/iptv_service.dart';

class TSeries {
  final String name;
  final String streamIcon;
  final String seriesId;
  final String categoryId;

  TSeries({
    required this.name,
    required this.streamIcon,
    required this.seriesId,
    required this.categoryId,
  });

  factory TSeries.fromJson(Map<String, dynamic> json) {
    return TSeries(
      name: json['name'] ?? '',
      streamIcon: json['cover'] ?? '',
      seriesId: json['series_id']?.toString() ?? '',
      categoryId: json['category_id'] ?? '',
    );
  }

  int get streamId => int.parse(seriesId);

  Future<String> get streamUrl => Future.value('');

}

class Episode {
  final String id;
  final String title;
  final String extension;
  final String plot;
  final String duration;
  final String cover;
  String? episodeStreamUrl;

  Episode({
    required this.id,
    required this.title,
    required this.extension,
    required this.plot,
    required this.duration,
    required this.cover,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      extension: json['container_extension'] ?? '',
      plot: json['info']?['plot'] ?? '',
      duration: json['info']?['duration'] ?? '',
      cover: json['info']?['movie_image'] ?? '',
    );
  }

  Future<String> get streamUrl async {
    if (episodeStreamUrl != null) return episodeStreamUrl!;

    final credentials = await IptvService.getSavedCredentials();
    final username = credentials['username'];
    final password = credentials['password'];
    final serverUrl = credentials['serverUrl'];

    episodeStreamUrl = '$serverUrl/series/$username/$password/$id.$extension?username=$username&password=$password';
    return episodeStreamUrl!;
  }
}

class Season {
  final String airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final int seasonNumber;
  final String cover;
  final String coverBig;
  final List<Episode> episodes;

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    required this.seasonNumber,
    required this.cover,
    required this.coverBig,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json, List<Episode> seasonEpisodes) {
    return Season(
      airDate: json['air_date'] ?? '',
      episodeCount: json['episode_count'] ?? 0,
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      seasonNumber: json['season_number'] ?? 1,
      cover: json['cover'] ?? '',
      coverBig: json['cover_big'] ?? '',
      episodes: seasonEpisodes,
    );
  }

  factory Season.defaultSeason(List<Episode> episodes) {
    return Season(
      airDate: '',
      episodeCount: episodes.length,
      id: 1,
      name: 'Season 1',
      overview: '',
      seasonNumber: 1,
      cover: '',
      coverBig: '',
      episodes: episodes,
    );
  }
}

class TSeriesDetails {
  final String name;
  final String cover;
  final String plot;
  final String cast;
  final String director;
  final String genre;
  final String releaseDate;
  final String rating;
  final String episodeRunTime;
  final String categoryId;
  final List<Season> seasons;

  TSeriesDetails({
    required this.name,
    required this.cover,
    required this.plot,
    required this.cast,
    required this.director,
    required this.genre,
    required this.releaseDate,
    required this.rating,
    required this.episodeRunTime,
    required this.categoryId,
    required this.seasons,
  });

  factory TSeriesDetails.fromJson(Map<String, dynamic> json) {
    List<Season> seasonsList = [];
    
    Map<String, dynamic> episodesMap = json['episodes'] ?? {};
    Map<int, List<Episode>> episodesBySeason = {};
    
    episodesMap.forEach((seasonKey, episodes) {
      int seasonNum = int.tryParse(seasonKey) ?? 1;
      List<Episode> seasonEpisodes = (episodes as List)
          .map((episode) => Episode.fromJson(episode))
          .toList();
      episodesBySeason[seasonNum] = seasonEpisodes;
    });
    List seasonsJson = json['seasons'] ?? [];
    if (seasonsJson.isEmpty && episodesBySeason.isNotEmpty) {
      // Create default season if seasons array is empty
      seasonsList.add(Season.defaultSeason(episodesBySeason[1] ?? []));
    } else {
      seasonsList = seasonsJson.map((season) {
        int seasonNum = season['season_number'] ?? 1;
        List<Episode> seasonEpisodes = episodesBySeason[seasonNum] ?? [];
        // Only add seasons that have episodes
        if (seasonEpisodes.isNotEmpty) {
          return Season.fromJson(season, seasonEpisodes);
        }
        return null;
      }).whereType<Season>().toList();
    }

    return TSeriesDetails(
      name: json['info']?['name'] ?? '',
      cover: json['info']?['cover'] ?? '',
      plot: json['info']?['plot'] ?? '',
      cast: json['info']?['cast'] ?? '',
      director: json['info']?['director'] ?? '',
      genre: json['info']?['genre'] ?? '',
      releaseDate: json['info']?['releaseDate'] ?? '',
      rating: json['info']?['rating'] ?? '',
      episodeRunTime: json['info']?['episode_run_time'] ?? '',
      categoryId: json['info']?['category_id'] ?? '',
      seasons: seasonsList,
    );
  }
}