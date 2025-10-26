import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';

class CategoryScreen extends StatelessWidget {
  final GroceryListModel model;

  const CategoryScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counts = model.categoryCounts();
    final categories = counts.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('All items'),
            subtitle: Text('${model.items.length} items'),
            onTap: () => Navigator.of(context).pop(''),
          ),
          const Divider(),
          ...categories.map(
            (c) => ListTile(
              title: Text(c),
              trailing: Text('${counts[c]}'),
              onTap: () => Navigator.of(context).pop(c),
            ),
          ),
        ],
      ),
    );
  }
}
