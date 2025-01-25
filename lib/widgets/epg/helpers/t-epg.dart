import 'dart:convert';

class TEPG {
  final String id;
  final String epgId;
  final String title;
  final String lang;
  final DateTime start;
  final DateTime end;
  final String description;
  final String channelId;
  final int startTimestamp;
  final int stopTimestamp;
  final bool nowPlaying;
  final bool hasArchive;

  TEPG({
    required this.id,
    required this.epgId,
    required this.title,
    required this.lang,
    required this.start,
    required this.end,
    required this.description,
    required this.channelId,
    required this.startTimestamp,
    required this.stopTimestamp,
    required this.nowPlaying,
    required this.hasArchive,
  });

  factory TEPG.fromJson(Map<String, dynamic> json) {
    String decodeBase64Text(String text) {
      try {
        return utf8.decode(base64Decode(text));
      } catch (e) {
        return text;
      }
    }

    return TEPG(
      id: json['id'] ?? '',
      epgId: json['epg_id'] ?? '',
      title: decodeBase64Text(json['title'] ?? ''),
      lang: json['lang'] ?? '',
      start: DateTime.parse(json['start'] ?? DateTime.now().toString()),
      end: DateTime.parse(json['end'] ?? DateTime.now().toString()),
      description: decodeBase64Text(json['description'] ?? ''),
      channelId: json['channel_id'] ?? '',
      startTimestamp: int.parse(json['start_timestamp'] ?? '0'),
      stopTimestamp: int.parse(json['stop_timestamp'] ?? '0'),
      nowPlaying: json['now_playing'] == 1,
      hasArchive: json['has_archive'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'epg_id': epgId,
        'title': title,
        'lang': lang,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'description': description,
        'channel_id': channelId,
        'start_timestamp': startTimestamp.toString(),
        'stop_timestamp': stopTimestamp.toString(),
        'now_playing': nowPlaying ? 1 : 0,
        'has_archive': hasArchive ? 1 : 0,
      };
}
