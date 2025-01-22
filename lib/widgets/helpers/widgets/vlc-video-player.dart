// import 'package:better_player_plus/better_player_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class BPVideoPlayer extends StatefulWidget {
//   final String streamUrl;
//   final String name;

//   const BPVideoPlayer({
//     Key? key,
//     required this.streamUrl,
//     required this.name,
//   }) : super(key: key);

//   @override
//   State<BPVideoPlayer> createState() => _VideoPlayerState();
// }

// class _VideoPlayerState extends State<BPVideoPlayer> {
//   late BetterPlayerController _betterPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
//       aspectRatio: 16 / 9,
//       fit: BoxFit.contain,
//       autoPlay: true,
//       looping: true,
//       deviceOrientationsAfterFullScreen: [
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ],
//       deviceOrientationsOnFullScreen: [
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ],
//       controlsConfiguration: BetterPlayerControlsConfiguration(
//         enableFullscreen: true,
//         enablePlayPause: true,
//         enableProgressBar: true,
//         enableProgressText: true,
//         showControlsOnInitialize: true,
//         loadingWidget: Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         ),
//       ),
//     );

//     BetterPlayerDataSource dataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
//       videoFormat: BetterPlayerVideoFormat.hls,
//     );

//     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
//     _betterPlayerController.setupDataSource(dataSource);
//   }

//   @override
//   void dispose() {
//     _betterPlayerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: BetterPlayer(
//             controller: _betterPlayerController,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BPVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final String name;

  const BPVideoPlayer({
    Key? key,
    required this.streamUrl,
    required this.name,
  }) : super(key: key);

  @override
  State<BPVideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<BPVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
      handleLifecycle: true,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        enablePlayPause: true,
        enableProgressBar: true,
        enableProgressText: true,
        showControlsOnInitialize: true,
        loadingWidget: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.streamUrl,
      // videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: true),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 50000,
        maxBufferMs: 100000,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
      headers: {
        "User-Agent": "AppleCoreMedia/1.0.0.17D47 (iPhone; U; CPU OS 13_3 like Mac OS X; en_us)",
        "Accept": "*/*",
        "Accept-Language": "en-US,en;q=0.9",
        "Accept-Encoding": "gzip, deflate, br"
      },
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),
      ),
    );
  }
}
