import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starhub/services/iptv_service.dart';
import 'dart:async';

import 'package:starhub/widgets/helpers/widgets/tile.dart';

class BPVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final String name;
  final bool isLiveTV;
  final List<dynamic>? channels;
  final int? selectedChannelIndex;

  const BPVideoPlayer({
    super.key,
    required this.streamUrl,
    required this.name,
    this.isLiveTV = false,
    this.channels,
    this.selectedChannelIndex,
  });

  @override
  State<BPVideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<BPVideoPlayer> {
  late BetterPlayerController _betterPlayerController;
  bool _showControls = true;
  Timer? _hideTimer;
  late int currentChannelIndex;
  late String currentChannelName;

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!widget.isLiveTV || widget.channels == null) {
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _handleTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void initState() {
    super.initState();
    currentChannelIndex = widget.selectedChannelIndex ?? 0;
    currentChannelName = widget.name;
    _initializePlayer();
    _startHideTimer();
  }

  void _initializePlayer() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      looping: true,
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
      videoFormat: widget.isLiveTV ? BetterPlayerVideoFormat.hls : null,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  void _switchChannel(int index) async {
    // Dispose old stream
    await _betterPlayerController.pause();
    await _betterPlayerController.clearCache();
    
    setState(() {
      currentChannelIndex = index;
      currentChannelName = widget.channels![index].name;
    });
    
    final channel = widget.channels![index];
    final newStreamUrl = await channel.streamUrl;
    
    BetterPlayerDataSource newDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      newStreamUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    
    await _betterPlayerController.setupDataSource(newDataSource);
  }
  Widget _buildChannelList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.channels?.length ?? 0,
        itemBuilder: (context, index) {
          final channel = widget.channels![index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                if (_showControls) {
                  _switchChannel(index);
                }
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  border: currentChannelIndex == index
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Tile(
                  streamId: channel.streamId,
                  name: channel.name,
                  streamUrl: '',
                  type: CategoryType.livetv,
                  imageUrl: channel.streamIcon,
                  horizontal: true,
                  customOnTap: () =>
                      _showControls ? _switchChannel(index) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _betterPlayerController.dispose();
    // Clear any cached video data
    _betterPlayerController.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,  // This ensures taps are detected everywhere
        onTap: _handleTap,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                  controller: _betterPlayerController,
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              currentChannelName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isLiveTV && widget.channels != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildChannelList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }}
