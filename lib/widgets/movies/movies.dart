import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/helpers/types/tmovie.dart';
import 'package:starhub/widgets/helpers/widgets/categories-compact.dart';
import 'package:starhub/widgets/loader/loader.dart';
import 'package:starhub/widgets/movies/helpers/slider.dart';
import 'package:starhub/widgets/movies/helpers/util.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  List<TMovie> _movies = [];
  List<TMovie> _topMovies = [];
  List<TCompactCategory<TMovie>> _categorizedMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchTopMovies();
  }

  Future<void> _fetchTopMovies() async {
    try {
      _movies = await IptvService.fetchMovies();
      final categories =
          await IptvService.fetchCategories(type: CategoryType.movies);
      if (mounted) {
        setState(() {
          _categorizedMovies = convertItemsPerCategory<TMovie>(
            _movies,
            categories,
            (movie) => movie.categoryId,
          );
          _topMovies = _categorizedMovies[0].items.take(5).toList();
        });
      }
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsCount = _categorizedMovies.isEmpty
        ? 2
        : _categorizedMovies.length + 1; // +1 for the slider
    return BaseScreen(
      currentIndex: 0,
      child: ListView.builder(
        itemCount: itemsCount,
        itemBuilder: (context, index) {
          if (index == 0) {
            return MovieSlider(movies: _topMovies);
          }
          if (_categorizedMovies.isEmpty) {
            return SizedBox(height: 200, child:const Center(child: LoaderOverlay()));
          } else {
            final TCompactCategory<TMovie> compactCategory =
                _categorizedMovies[index - 1];
            return CategoriesCompact(
              categoryName: compactCategory.category.name,
              items: compactCategory.items,
              type: CategoryType.movies,
            );
          }
        },
      ),
    );
  }
}
