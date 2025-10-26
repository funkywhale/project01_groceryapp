import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';
import '../widgets/grocery_tile.dart';
import 'add_edit_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  final GroceryListModel model;

  const HomeScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _filterCategory;
  String _search = '';

  void _openAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(model: widget.model)),
    );
  }

  void _openCategory() async {
    final selected = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => CategoryScreen(model: widget.model)),
    );
    if (selected != null)
      setState(() => _filterCategory = selected.isEmpty ? null : selected);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = widget.model.groupByCategory(
      query: _search,
      category: _filterCategory,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Grocery List'),
        actions: [
          IconButton(
            onPressed: _openCategory,
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: grouped.isEmpty
          ? const Center(child: Text('No items yet — tap + to add one'))
          : ListView.builder(
              itemCount: grouped.keys.length,
              itemBuilder: (context, idx) {
                final category = grouped.keys.elementAt(idx);
                final items = grouped[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ...items.map(
                      (it) => GroceryTile(
                        item: it,
                        onEdit: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditScreen(model: widget.model, item: it),
                            ),
                          );
                          setState(() {});
                        },
                        onDelete: () {
                          widget.model.removeItem(it.id);
                          setState(() {});
                        },
                        onTogglePurchased: () {
                          widget.model.togglePurchased(it.id);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
