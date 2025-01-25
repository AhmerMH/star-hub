import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/widgets/categories-compact.dart';
import 'package:starhub/widgets/loader/loader.dart';

// Colors
const kBackgroundColor = Color(0xFF1A1A1A);
const kTextColor = Colors.white;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, dynamic>? _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await IptvService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load favorites')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(color: kTextColor),
        ),
      ),
      body: _isLoading
          ? const LoaderOverlay()
          : _favorites == null || 
            (_favorites!['live'].isEmpty && 
             _favorites!['movies'].isEmpty && 
             _favorites!['series'].isEmpty)
              ? const Center(
                  child: Text(
                    'No favorites added yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((_favorites?['live'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Live TV',
                          items: _favorites?['live'] ?? [],
                          type: CategoryType.livetv,
                          noLimit: true,
                        ),
                      if ((_favorites?['movies'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Movies',
                          items: _favorites?['movies'] ?? [],
                          type: CategoryType.movies,
                          noLimit: true,
                        ),
                      if ((_favorites?['series'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Series',
                          items: _favorites?['series'] ?? [],
                          type: CategoryType.series,
                          noLimit: true,
                        ),
                    ],
                  ),
                ),
    );
  }
}
