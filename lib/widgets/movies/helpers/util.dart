import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/helpers/types/t-live-tv.dart';

class TCompactCategory<T> {
  final TCategory category;
  final List<T> items;

  TCompactCategory({
    required this.category,
    required this.items,
  });
}

List<TCompactCategory<T>> convertItemsPerCategory<T>(List<T> items,
    List<TCategory> categories, String Function(T) getCategoryId) {
  final Map<String, List<T>> itemsByCategory = {};

  // Group items by category ID
  for (var item in items) {
    // Skip live TV items with missing stream icons
    if (item is TLiveChannel && (item.streamIcon == null || item.streamIcon.isEmpty)) {
      continue;
    }
    
    final categoryId = getCategoryId(item);
    if (!itemsByCategory.containsKey(categoryId)) {
      itemsByCategory[categoryId] = [];
    }
    itemsByCategory[categoryId]!.add(item);
  }

  // Create TCompactCategory objects
  return categories.map((category) {
    return TCompactCategory<T>(
      category: category,
      items: itemsByCategory[category.id] ?? [],
    );
  }).toList();
}