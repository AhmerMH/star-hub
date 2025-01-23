import 'package:flutter/material.dart';
import 'package:starhub/widgets/helpers/widgets/bpp-video-player.dart';
import 'package:starhub/widgets/loader/loader.dart';
import '../../../services/iptv_service.dart';
import '../../helpers/types/t-series.dart';

// Colors
const kBackgroundColor = Color(0xFF1A1A1A);
const kPillBackgroundColor = Color(0xFF4A4A4A);
const kSelectedPillColor = Color(0xFFE50914);
const kEpisodeBackgroundColor = Color(0xFF2D2D2D);
const kTextColor = Colors.white;
const kBorderColor = Colors.white;

class SeriesDetails extends StatefulWidget {
  final int streamId;

  const SeriesDetails({
    super.key,
    required this.streamId,
  });

  @override
  State<SeriesDetails> createState() => _SeriesDetailsState();
}

class _SeriesDetailsState extends State<SeriesDetails> {
  TSeriesDetails? seriesDetails;
  int selectedSeasonIndex = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSeriesDetails();
  }

  Future<void> _loadSeriesDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final details = await IptvService.getSeriesDetails(widget.streamId);
      if (mounted) {
        setState(() {
          seriesDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load series details';
          isLoading = false;
        });
      }
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: kTextColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            error!,
            style: const TextStyle(color: kTextColor),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSelectedPillColor,
              foregroundColor: kTextColor,
            ),
            onPressed: _loadSeriesDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: LoaderOverlay()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: _buildErrorView(),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full width poster image
                Image.network(
                  seriesDetails!.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: kPillBackgroundColor,
                    child: const Icon(Icons.error, color: kTextColor),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        seriesDetails!.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Seasons Pills
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: seriesDetails!.seasons.length,
                          itemBuilder: (context, index) {
                            final season = seriesDetails!.seasons[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedSeasonIndex = index),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: selectedSeasonIndex == index
                                        ? kSelectedPillColor
                                        : kPillBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Season ${season.seasonNumber}',
                                    style: const TextStyle(
                                      color: kTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Episodes List
                      Container(
                        height: MediaQuery.of(context).size.height *
                            0.4, // Fixed height for scrollable area
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: seriesDetails!
                              .seasons[selectedSeasonIndex].episodes.length,
                          itemBuilder: (context, index) {
                            final episode = seriesDetails!
                                .seasons[selectedSeasonIndex].episodes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kEpisodeBackgroundColor,
                                  border: Border.all(color: kBorderColor),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    episode.title,
                                    style: const TextStyle(
                                        color: kTextColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    'Duration: ${episode.duration}',
                                    style: const TextStyle(
                                        color: kTextColor,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.play_circle_outline,
                                          color: kTextColor,
                                          size: 32),
                                      onPressed: () async {
                                        final streamUrl =
                                            await episode.streamUrl;
                                        if (mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BPVideoPlayer(
                                                streamUrl: streamUrl,
                                                name: episode.title,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
                icon: const Icon(Icons.arrow_back, color: kTextColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
