
import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/widgets/categories-compact.dart';
import 'package:starhub/widgets/loader/loader.dart';

// Colors
const kBackgroundColor = Color(0xFF1A1A1A);
const kTextColor = Colors.white;
const kInputBorderColor = Colors.white24;
const kInputFocusedBorderColor = Colors.white;
const kSearchButtonColor = Color(0xFFE50914);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _searchResults;
  bool _isLoading = false;

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final results = await IptvService.searchContent(_searchController.text);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Search failed. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: kTextColor),
                cursorColor: kTextColor,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kInputBorderColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kInputFocusedBorderColor),
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: kSearchButtonColor),
              onPressed: _performSearch,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoaderOverlay()
          : _searchResults == null
              ? const Center(
                  child: Text(
                    'Search for movies, series or live TV',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((_searchResults?['live'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Live TV',
                          items: _searchResults?['live'] ?? [],
                          type: CategoryType.livetv,
                          noLimit: true,
                        ),
                      if ((_searchResults?['movies'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Movies',
                          items: _searchResults?['movies'] ?? [],
                          type: CategoryType.movies,
                          noLimit: true,
                        ),
                      if ((_searchResults?['series'] ?? []).isNotEmpty)
                        CategoriesCompact(
                          categoryName: 'Series',
                          items: _searchResults?['series'] ?? [],
                          type: CategoryType.series,
                          noLimit: true,
                        ),
                      if ((_searchResults?['live'] ?? []).isEmpty &&
                          (_searchResults?['movies'] ?? []).isEmpty &&
                          (_searchResults?['series'] ?? []).isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No results found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
