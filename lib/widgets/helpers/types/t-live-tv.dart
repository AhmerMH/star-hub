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
      streamId: json['stream_id'] ?? 0,
      tvArchive: json['tv_archive'] ?? 0,
      name: json['name'].toString(),
      streamType: json['stream_type'].toString(),
      streamIcon: json['stream_icon'].toString(),
      epgChannelId: json['epg_channel_id'].toString(),
      added: json['added'].toString(),
      categoryId: json['category_id'].toString(),
      customSid: json['custom_sid'].toString(),
      directSource: json['direct_source'].toString(),
      tvArchiveDuration: json['tv_archive_duration'].toString(),
    );
  }

  Future<String> get streamUrl async {
    if (liveStreamUrl != null) return liveStreamUrl!;

    final credentials = await IptvService.getSavedCredentials();
    final username = credentials['username'];
    final password = credentials['password'];
    final serverUrl = credentials['serverUrl'];

    liveStreamUrl =
        '$serverUrl/live/$username/$password/$streamId.m3u8?username=$username&password=$password';
    return liveStreamUrl!;
  }

  Map<String, dynamic> toJson() {
    return {
      'num': num,
      'name': name,
      'stream_type': streamType,
      'stream_id': streamId,
      'stream_icon': streamIcon,
      'epg_channel_id': epgChannelId,
      'added': added,
      'category_id': categoryId,
      'custom_sid': customSid,
      'tv_archive': tvArchive,
      'direct_source': directSource,
      'tv_archive_duration': tvArchiveDuration,
    };
  }
}
