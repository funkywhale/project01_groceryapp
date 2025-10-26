import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';
import '../screens/add_edit_screen.dart';
import '../widgets/grocery_tile.dart';

class MainTabs extends StatefulWidget {
  final GroceryListModel model;

  const MainTabs({Key? key, required this.model}) : super(key: key);

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(model: widget.model)),
    );
    setState(() {});
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = (category == null || category.isEmpty)
          ? null
          : category;
      _tabController.index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Grocery List'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeTab(model: widget.model, selectedCategory: _selectedCategory),
          CategoryTab(model: widget.model, onSelected: _onCategorySelected),
          const SettingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _openAdd,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class HomeTab extends StatefulWidget {
  final GroceryListModel model;
  final String? selectedCategory;

  const HomeTab({Key? key, required this.model, this.selectedCategory})
    : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _search = '';
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _filterCategory = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(covariant HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() => _filterCategory = widget.selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = widget.model.groupByCategory(
      query: _search,
      category: _filterCategory,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search items',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('Tap + to add items to list'))
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
                                    builder: (_) => AddEditScreen(
                                      model: widget.model,
                                      item: it,
                                    ),
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
          ),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final GroceryListModel model;
  final void Function(String?) onSelected;

  const CategoryTab({Key? key, required this.model, required this.onSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counts = model.categoryCounts();
    final categories = counts.keys.toList()..sort();

    return ListView(
      children: [
        ListTile(
          title: const Text('All items'),
          subtitle: Text('${model.items.length} items'),
          onTap: () => onSelected(''),
        ),
        const Divider(),
        ...categories.map(
          (c) => ListTile(
            title: Text(c),
            trailing: Text('${counts[c]}'),
            onTap: () => onSelected(c),
          ),
        ),
      ],
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings placeholder'));
  }
}
