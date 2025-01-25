import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/types/tmovie.dart';
import 'package:starhub/widgets/helpers/widgets/bpp-video-player.dart';
import 'package:starhub/widgets/loader/loader.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int streamId;
  final String name;
  final String streamUrl;

  const MovieDetailsScreen({
    super.key,
    required this.streamId,
    required this.name,
    required this.streamUrl,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Future<TMovieDetail?>? _movieDetailsFuture;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = IptvService.getMovieDetails(widget.streamId);
  }

  Widget _buildRatingStars(String rating) {
    final numRating = double.tryParse(rating) ?? 0;
    final fullStars = numRating.floor();
    final hasHalfStar = (numRating - fullStars) >= 0.5;

    return Row(
      children: [
        Row(
          children: List.generate(10, (index) {
            if (index < fullStars) {
              return const Icon(Icons.star, size: 20, color: Colors.yellow);
            } else if (index == fullStars && hasHalfStar) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    stops: [0, 0.5, 0.5],
                    colors: [Colors.yellow, Colors.yellow, Colors.grey],
                  ).createShader(rect);
                },
                child: const Icon(Icons.star, size: 20),
              );
            }
            return const Icon(Icons.star, size: 20, color: Colors.grey);
          }),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<TMovieDetail?>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoaderOverlay();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Failed to load movie details',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          child: Image.network(
                            movie.cover,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.red[900],
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BPVideoPlayer(
                                    streamUrl: widget.streamUrl,
                                    name: movie.name,
                                  ),
                                ),
                              );
                            },
                            icon: const Text(
                              'Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            label: const Icon(
                              Icons.play_circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Duration', movie.duration),
                          _buildInfoRow('Release Date', movie.releaseDate),
                          _buildInfoRow('Genre', movie.genre),
                          const SizedBox(height: 8),
                          _buildInfoRow('Rating',
                              movie.rating == "0" ? 'N/A' : movie.rating),
                          if (movie.rating != "0")
                            _buildRatingStars(movie.rating),
                          const SizedBox(height: 16),
                          _buildInfoRow('Cast', movie.cast),
                          const SizedBox(height: 16),
                          _buildInfoRow('Description', movie.plot),
                          const SizedBox(height: 16),
                          _buildInfoRow('Director', movie.director),
                          _buildInfoRow('Country', movie.country),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
