import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';
import 'package:starhub/widgets/helpers/types/t-series.dart';
import 'package:starhub/widgets/helpers/widgets/categories-compact.dart';
import 'package:starhub/widgets/loader/loader.dart';
import 'package:starhub/widgets/movies/helpers/util.dart';

const Color fontColor = Colors.white;

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<TCompactCategory<TSeries>> _categorizedSeries = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final series = await IptvService.fetchSeries();
      final categories =
          await IptvService.fetchCategories(type: CategoryType.series);
      IptvService.getSeriesDetails(series[0].streamId);
      setState(() {
        _categorizedSeries = convertItemsPerCategory<TSeries>(
          series,
          categories,
          (seri) => seri.categoryId,
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
        currentIndex: 1,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error ?? 'An error occurred',
                style: const TextStyle(color: fontColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return BaseScreen(
      currentIndex: 1,
      child: _categorizedSeries.isEmpty
          ? const LoaderOverlay()
          : ListView.builder(
              itemCount: _categorizedSeries.length,
              itemBuilder: (context, index) {
                final category = _categorizedSeries[index];
                return CategoriesCompact(
                  categoryName: category.category.name,
                  items: category.items,
                  type: CategoryType.series,
                );
              },
            ),
    );
  }
}
