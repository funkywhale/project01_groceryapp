import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'grocery_item.dart';

class GroceryListModel extends ChangeNotifier {
  final List<GroceryItem> _items = [];

  UnmodifiableListView<GroceryItem> get items => UnmodifiableListView(_items);

  void addItem(GroceryItem item) {
    _items.add(item);
    notifyListeners();
    _saveToPrefs();
  }

  GroceryItem createAndAdd({
    required String name,
    required int quantity,
    required String category,
    String? notes,
    bool priority = false,
    double? price,
  }) {
    final item = GroceryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      category: category,
      notes: notes,
      price: price,
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
      _saveToPrefs();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveToPrefs();
  }

  void togglePurchased(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final it = _items[idx];
      _items[idx] = it.copyWith(purchased: !it.purchased);
      notifyListeners();
      _saveToPrefs();
    }
  }

  void clearPurchased() {
    _items.removeWhere((e) => e.purchased);
    notifyListeners();
    _saveToPrefs();
  }

  double totalEstimatedPrice({String? category}) {
    final list = search(category: category);
    double total = 0.0;
    for (final it in list) {
      final p = it.price ?? 0.0;
      total += p * it.quantity;
    }
    return total;
  }

  static const _prefsKey = 'grocery_items_v1';

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _items.map((e) => e.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));
    } catch (_) {
      // ignore
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_prefsKey);
      if (s == null) return;
      final List<dynamic> arr = jsonDecode(s) as List<dynamic>;
      _items.clear();
      for (final e in arr) {
        if (e is Map<String, dynamic>) {
          _items.add(GroceryItem.fromJson(e));
        } else if (e is Map) {
          _items.add(GroceryItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      notifyListeners();
    } catch (_) {
      // ignore
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
      if (category != null && category.isNotEmpty && it.category != category) {
        return false;
      }
      if (q == null || q.isEmpty) {
        return true;
      }
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
