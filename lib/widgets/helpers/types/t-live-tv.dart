import 'package:starhub/services/iptv_service.dart';

class TLiveChannel {
  final int num;
  final String name;
  final String streamType;
  final int streamId;
  final String streamIcon;
  final String epgChannelId;
  final String added;
  final String categoryId;
  final String customSid;
  final int tvArchive;
  final String directSource;
  final String tvArchiveDuration;
  String? liveStreamUrl;

  TLiveChannel({
    required this.num,
    required this.name,
    required this.streamType,
    required this.streamId,
    required this.streamIcon,
    required this.epgChannelId,
    required this.added,
    required this.categoryId,
    required this.customSid,
    required this.tvArchive,
    required this.directSource,
    required this.tvArchiveDuration,
  });

  factory TLiveChannel.fromJson(Map<String, dynamic> json) {
    return TLiveChannel(
      num: json['num'] ?? 0,
      name: json['name'] ?? '',
      streamType: json['stream_type'] ?? '',
      streamId: json['stream_id'] ?? 0,
      streamIcon: json['stream_icon'] ?? '',
      epgChannelId: json['epg_channel_id'] ?? '',
      added: json['added'] ?? '',
      categoryId: json['category_id'] ?? '',
      customSid: json['custom_sid'] ?? '',
      tvArchive: json['tv_archive'] ?? 0,
      directSource: json['direct_source'] ?? '',
      tvArchiveDuration: json['tv_archive_duration'].toString(),
    );
  }

  Future<String> get streamUrl async {
    if (liveStreamUrl != null) return liveStreamUrl!;

    final credentials = await IptvService.getSavedCredentials();
    final username = credentials['username'];
    final password = credentials['password'];
    final serverUrl = credentials['serverUrl'];

    liveStreamUrl = '$serverUrl/player_api.php?username=$username&password=$password&stream=$streamId&type=hls';
        // '$serverUrl/live/$streamId.m3u8?username=$username&password=$password';
    return liveStreamUrl!;
  }
}
