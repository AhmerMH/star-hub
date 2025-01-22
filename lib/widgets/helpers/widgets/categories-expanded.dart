import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/widgets/tile.dart';

const Color fontColor = Colors.white;
const Color backgroundColor = Colors.black;
final Color backgroundListItem = Colors.grey[850]!;
const double titleFontSize = 20.0;
const double gridSpacing = 12.0;

class CategoriesExpanded extends StatelessWidget {
  final String categoryName;
  final List<dynamic> items;
  final CategoryType type;
  final bool columnView;

  const CategoriesExpanded({
    super.key,
    required this.categoryName,
    required this.items,
    required this.type,
    this.columnView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            color: fontColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: fontColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (columnView) {
                    return _buildListView();
                  } else {
                    return _buildResponsiveGrid(constraints.maxWidth);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        dynamic item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: gridSpacing),
          child: FutureBuilder<String>(
            future: item!.streamUrl,
            builder: (context, snapshot) {
              return Container(
                decoration: BoxDecoration(
                  color: backgroundListItem,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Left column - Icon
                    Container(
                      width: 84,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      child: Image.network(
                        item.streamIcon,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.tv,
                          color: fontColor,
                          size: 40,
                        ),
                      ),
                    ),

                    // Middle column - Title and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: fontColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Added: ${DateTime.now().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: fontColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.play_circle_outline),
                      color: fontColor,
                      iconSize: 32,
                      onPressed: () {
                        // Your existing navigation logic
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResponsiveGrid(double width) {
    // Calculate number of columns based on screen width
    int crossAxisCount = _calculateCrossAxisCount(width);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        dynamic item = items[index];
        return FutureBuilder<String>(
          future: item!.streamUrl,
          builder: (context, snapshot) {
            return Tile(
              streamId: item.streamId,
              name: item.name,
              streamUrl: snapshot.data ?? '',
              type: type,
              imageUrl: item.streamIcon,
            );
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width <= 600) return 3; // Mobile
    if (width <= 900) return 4; // Tablet
    if (width <= 1200) return 5; // Small Desktop
    if (width <= 1800) return 6; // Large Desktop
    return 6; // TV or larger screens
  }
}
