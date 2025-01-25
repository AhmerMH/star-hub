import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/epg/helpers/t-epg.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';
import 'package:starhub/widgets/movies/helpers/util.dart';
import 'package:starhub/widgets/loader/loader.dart';

// Colors
const kBackgroundColor = Colors.black;
const kPillBackgroundColor = Color(0xFF4A4A4A);
const kSelectedPillColor = Color(0xFFE50914);
const kChannelBackgroundColor = Color(0xFF3D3D3D); // Lighter gray
const kTextColor = Colors.white;
const kEpgDateColor = Colors.yellow;

class EpgScreen extends StatefulWidget {
  const EpgScreen({super.key});

  @override
  State<EpgScreen> createState() => _EpgScreenState();
}

class _EpgScreenState extends State<EpgScreen> {
  List<TCompactCategory<TLiveChannel>>? _categorizedChannels;
  bool isLoading = true;
  String? error;
  int selectedCategoryIndex = 0;
  int selectedChannelIndex = 0;
  List<TEPG>? currentEpgData;
  bool isLoadingEpg = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final Future<List<TLiveChannel>> channelsFuture =
          IptvService.fetchLiveChannels();
      final Future<List<TCategory>> categoriesFuture =
          IptvService.fetchCategories(type: CategoryType.livetv);

      final results = await Future.wait([channelsFuture, categoriesFuture]);

      if (mounted) {
        setState(() {
          _categorizedChannels = convertItemsPerCategory<TLiveChannel>(
            results[0] as List<TLiveChannel>,
            results[1] as List<TCategory>,
            (channel) => channel.categoryId,
          );
          isLoading = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          error = 'Failed to load EPG data';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEpgData(String epgChannelId, String categoryId) async {
    setState(() {
      isLoadingEpg = true;
      currentEpgData = null;
    });

    final epgData = await IptvService.getEpgDetails(epgChannelId, categoryId);

    if (mounted) {
      setState(() {
        currentEpgData = epgData;
        isLoadingEpg = false;
      });
    }
  }

  void _onChannelSelected(int index) {
    setState(() {
      selectedChannelIndex = index;
    });
    final channel = _categorizedChannels![selectedCategoryIndex].items[index];
    _loadEpgData(channel.streamId.toString(), channel.categoryId);
  }

  Widget _buildEpgContent() {
    if (isLoadingEpg) {
      return const Center(child: LoaderOverlay());
    }

    if (currentEpgData == null || currentEpgData!.isEmpty) {
      return const Center(
        child: Text(
          'No EPG data available',
          style: TextStyle(
            color: kTextColor,
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: currentEpgData!.length,
      itemBuilder: (context, index) {
        final epg = currentEpgData![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                epg.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Start: ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: DateFormat('MMMM d, y, h:mm a').format(epg.start),
                      style: const TextStyle(color: kEpgDateColor),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'End: ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: DateFormat('MMMM d, y, h:mm a').format(epg.end),
                      style: const TextStyle(color: kEpgDateColor),
                    ),
                  ],
                ),
              ),              const SizedBox(height: 8),
              if (epg.description != '')
                Text(
                  'Description: ${epg.description}',
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
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
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 3,
      child: isLoading
          ? const LoaderOverlay()
          : error != null
              ? _buildErrorView()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'EPG Guide',
                        style: TextStyle(
                          color: kTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_categorizedChannels != null) ...[
                      // Categories Pills
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categorizedChannels!.length,
                          itemBuilder: (context, index) {
                            final category =
                                _categorizedChannels![index].category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryIndex = index;
                                    selectedChannelIndex = 0;
                                  });
                                  // Fetch EPG for the first channel in the new category
                                  final firstChannel =
                                      _categorizedChannels![index].items[0];
                                  _loadEpgData(firstChannel.streamId.toString(),
                                      firstChannel.categoryId);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedCategoryIndex == index
                                        ? kSelectedPillColor
                                        : kPillBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: kTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Two-column layout
                      Expanded(
                        child: Row(
                          children: [
                            // Channels List (1/3 width)
                            getLeftChannelColumn(),
                            // EPG Content (2/3 width)
                            Expanded(
                              flex: 2,
                              child: _buildEpgContent(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Expanded getLeftChannelColumn() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xFF2D2D2D),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _categorizedChannels![selectedCategoryIndex].items.length,
          itemBuilder: (context, index) {
            final channel =
                _categorizedChannels![selectedCategoryIndex].items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  _onChannelSelected(index);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedChannelIndex == index
                        ? kSelectedPillColor
                        : kChannelBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    channel.name,
                    style: const TextStyle(
                      color: kTextColor,
                    ),
                    maxLines: null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
