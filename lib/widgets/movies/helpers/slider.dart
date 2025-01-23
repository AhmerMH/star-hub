import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:starhub/widgets/helpers/types/tmovie.dart';
import 'package:starhub/widgets/helpers/widgets/bpp-video-player.dart';
import 'package:starhub/widgets/loader/horizontal-loader.dart';
import 'package:starhub/widgets/movies/helpers/movie-detail.dart';

// Colors remain unchanged
const Color overlayStartColor = Colors.transparent;
final Color overlayEndColor = Colors.black.withOpacity(0.8);
final Color imageBlurColor = Colors.black.withOpacity(0.3);
const Color titleTextColor = Colors.white;
const Color favoriteButtonColor = Colors.white;
const Color favoriteButtonTextColor = Colors.white;
const Color favoriteButtonIconColor = Colors.white;
final Color playButtonColor = Colors.red[900]!;
const Color playButtonTextColor = Colors.white;
const Color playButtonIconColor = Colors.white;

class MovieSlider extends StatefulWidget {
  final List<TMovie> movies;

  const MovieSlider({required this.movies, super.key});

  @override
  State<MovieSlider> createState() => _MovieSliderState();
}

class _MovieSliderState extends State<MovieSlider> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < (widget.movies.length - 1)) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        final height = isLandscape
            ? MediaQuery.of(context).size.height * 0.5
            : MediaQuery.of(context).size.height * 0.3;

        return SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.movies.isEmpty ? 1 : widget.movies.length,
            itemBuilder: (context, index) {
              if (widget.movies.isEmpty) {
                return _buildSliderItem(null);
              }
              return _buildSliderItem(widget.movies[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSliderItem(dynamic movie) {
    final blurEffect = widget.movies.isEmpty ? 0.0 : 3.0;

    return GestureDetector(
      onTap: () async {
        if (movie != null) {
          final streamUrl = await movie.streamUrl;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(
                streamId: movie.streamId,
                name: movie.name,
                streamUrl: streamUrl,
              ),
            ),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          const titleFontSize = 32.0;
          const buttonSpacing = 16.0;
          const paddingSize = 20.0;

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: movie?.streamIcon != null
                    ? NetworkImage(movie?.streamIcon)
                    : const AssetImage('assets/images/slider_placeholder.jpg')
                        as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  imageBlurColor,
                  BlendMode.overlay,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [overlayStartColor, overlayEndColor],
                ),
              ),
              padding: const EdgeInsets.all(paddingSize),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: blurEffect, sigmaY: blurEffect),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: movie?.streamIcon != null
                              ? NetworkImage(movie?.streamIcon)
                              : const AssetImage(
                                      'assets/images/slider_placeholder.jpg')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            imageBlurColor,
                            BlendMode.overlay,
                          ),
                        ),
                      ),
                    ),
                  ),
                      Flexible(
                        child: Text(
                          movie?.name ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: titleTextColor,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: buttonSpacing),
                      movie?.name != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FloatingActionButton.extended(
                                  heroTag: 'favorite_${movie?.streamId ?? 0}',
                                  onPressed: () {
                                    // Favorite functionality
                                  },
                                  backgroundColor: Colors.transparent,
                                  label: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.favorite_border,
                                          color: favoriteButtonIconColor),
                                      Text('Favorite',
                                          style: TextStyle(
                                              color: favoriteButtonTextColor,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: buttonSpacing),
                                FloatingActionButton.extended(
                                  heroTag: 'play_${movie?.streamId ?? 0}',
                                  onPressed: () async {
                                    final streamUrl = await movie.streamUrl;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BPVideoPlayer(
                                          streamUrl: streamUrl,
                                          name: movie.name,
                                        ),
                                      ),
                                    );
                                  },
                                  backgroundColor: playButtonColor,
                                  icon: const Text('Play',
                                      style: TextStyle(color: playButtonTextColor)),
                                  label: const Icon(Icons.play_circle,
                                      color: playButtonIconColor),
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 10,
                              child: HLoaderOverlay(),
                            ),
                    ],
                  );
                }
              ),
            ),
          );      },
      ),
    );
  }
}
