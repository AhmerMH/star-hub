import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:starhub/services/credentials_service.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/movies/helpers/slider.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final _dio = Dio();
  List<dynamic> _movies = [];
  List<dynamic> _topMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchTopMovies();
  }

  Future<void> _fetchTopMovies() async {
    try {
      _movies = await IptvService.fetchMovies();

      if (mounted) {
        setState(() {
          _topMovies = _movies.take(5).toList();
        });
      }
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 0,
      child: Container(
        child: Column(
          children: [
            MovieSlider(movies: _topMovies),
          ],
        ),
      ),
    );
  }
}
