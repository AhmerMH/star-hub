import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';
import 'package:starhub/widgets/helpers/widgets/categories-compact.dart';
import 'package:starhub/widgets/loader/loader.dart';
import 'package:starhub/widgets/movies/helpers/util.dart';

const Color fontColor = Colors.white;

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  List<TCompactCategory<TLiveChannel>> _categorizedChannels = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final channels = await IptvService.fetchLiveChannels();
      final categories =
          await IptvService.fetchCategories(type: CategoryType.livetv);
      setState(() {
        _categorizedChannels = convertItemsPerCategory<TLiveChannel>(
          channels,
          categories,
          (channel) => channel.categoryId,
        );
      });
    } catch (err) {
      setState(() {
        error = 'An error occured. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return BaseScreen(
        currentIndex: 2,
        child: Center(
          child: Text(error ?? 'An error occured',
              style: const TextStyle(color: fontColor)),
        ),
      );
    }

    return BaseScreen(
      currentIndex: 2,
      child: error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error ?? 'An error occurred',
                      style: const TextStyle(color: fontColor)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _categorizedChannels.isEmpty
              ? const LoaderOverlay()
              : ListView.builder(
                  itemCount: _categorizedChannels.length,
                  itemBuilder: (context, index) {
                    final category = _categorizedChannels[index];
                    return CategoriesCompact(
                      categoryName: category.category.name,
                      items: category.items,
                      type: CategoryType.livetv,
                    );
                  },
                ),
    );  }
}
