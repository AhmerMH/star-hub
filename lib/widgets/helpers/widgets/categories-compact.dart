import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/widgets/categories-expanded.dart';
import 'package:starhub/widgets/helpers/widgets/tile.dart';

const Color fontColor = Colors.white;

class CategoriesCompact extends StatelessWidget {
  final String categoryName;
  final List<dynamic> items;
  final CategoryType type;
  final bool noLimit;
  static const height = 180.0;

  const CategoriesCompact({
    super.key,
    required this.categoryName,
    required this.items,
    required this.type,
    this.noLimit = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryName.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: fontColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoriesExpanded(
                        categoryName: categoryName,
                        items: items,
                        type: type,
                        columnView: type == CategoryType.livetv,
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                          color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: fontColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height, // Adjust based on your needs
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: noLimit ? items.length : (items.length > 10 ? 10 : items.length),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              dynamic item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Focus(
                  child: FutureBuilder<String>(
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}