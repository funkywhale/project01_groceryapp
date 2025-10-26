import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'grocery_item.dart';

class GroceryListModel extends ChangeNotifier {
  final List<GroceryItem> _items = [];


  UnmodifiableListView<GroceryItem> get items => UnmodifiableListView(_items);

  void addItem(GroceryItem item) {
    _items.add(item);
    notifyListeners();
  }

  GroceryItem createAndAdd({
    required String name,
    required int quantity,
    required String category,
    String? notes,
    bool priority = false,
  }) {
    final item = GroceryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      category: category,
      notes: notes,
      priority: priority,
    );
    addItem(item);
    return item;
  }

  void updateItem(String id, GroceryItem updated) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void togglePurchased(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final it = _items[idx];
      _items[idx] = it.copyWith(purchased: !it.purchased);
      notifyListeners();
    }
  }

  Map<String, int> categoryCounts() {
    final map = <String, int>{};
    for (final it in _items) {
      map[it.category] = (map[it.category] ?? 0) + 1;
    }
    return map;
  }

  List<GroceryItem> search({String? query, String? category}) {
    final q = query?.toLowerCase();
    return _items.where((it) {
      if (category != null && category.isNotEmpty && it.category != category)
        return false;
      if (q == null || q.isEmpty) return true;
      return it.name.toLowerCase().contains(q) ||
          (it.notes ?? '').toLowerCase().contains(q);
    }).toList();
  }


  Map<String, List<GroceryItem>> groupByCategory({
    String? query,
    String? category,
  }) {
    final filtered = search(query: query, category: category);
    final map = <String, List<GroceryItem>>{};
    for (final it in filtered) {
      map.putIfAbsent(it.category, () => []).add(it);
    }

    for (final k in map.keys) {
      map[k]!.sort((a, b) {
        if (a.priority && !b.priority) return -1;
        if (!a.priority && b.priority) return 1;
        return a.name.compareTo(b.name);
      });
    }
    return map;
  }
}
