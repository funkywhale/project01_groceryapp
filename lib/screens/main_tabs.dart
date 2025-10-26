import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';
import '../screens/add_edit_screen.dart';
import '../widgets/grocery_tile.dart';

class MainTabs extends StatefulWidget {
  final GroceryListModel model;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const MainTabs({
    super.key,
    required this.model,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_HomeTabState> _homeKey = GlobalKey<_HomeTabState>();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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

  Future<void> _confirmClearPurchased() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear purchased items?'),
        content: const Text(
          'This will permanently remove all checked (purchased) items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _homeKey.currentState?.clearPurchased();
    }
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
      body: Stack(
        children: [
          // Background gradient depending on light/dark theme
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.light
                      ? const [Color(0xFFF5EDE3), Color(0xFFEDE3D6)]
                      : const [Color(0xFF0E1113), Color(0xFF15191C)],
                ),
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: [
              HomeTab(
                key: _homeKey,
                model: widget.model,
                selectedCategory: _selectedCategory,
              ),
              CategoryTab(model: widget.model, onSelected: _onCategorySelected),
              SettingsTab(
                model: widget.model,
                themeMode: widget.themeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedBuilder(
                  animation: widget.model,
                  builder: (context, _) {
                    final onHome = _tabController.index == 0;
                    final hasPurchased = widget.model.items.any(
                      (e) => e.purchased,
                    );
                    final show = onHome && hasPurchased;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.95,
                            end: 1.0,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: show
                          ? FloatingActionButton(
                              key: const ValueKey('clearFab'),
                              onPressed: _confirmClearPurchased,
                              backgroundColor: Colors.redAccent,
                              tooltip: 'Clear purchased',
                              child: const Icon(Icons.delete_sweep),
                            )
                          : const SizedBox.shrink(key: ValueKey('noClearFab')),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim),
            child: child,
          ),
        ),
        child: _tabController.index == 0
            ? FloatingActionButton(
                key: const ValueKey('addFab'),
                onPressed: _openAdd,
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink(key: ValueKey('noAddFab')),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final GroceryListModel model;
  final String? selectedCategory;

  const HomeTab({super.key, required this.model, this.selectedCategory});

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
    final visible = widget.model.search(
      query: _search,
      category: _filterCategory,
    );
    final total = visible.fold<double>(
      0.0,
      (acc, it) => acc + ((it.price ?? 0.0) * it.quantity),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated total',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
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

  void clearPurchased() {
    widget.model.clearPurchased();
    setState(() {});
  }
}

class CategoryTab extends StatelessWidget {
  final GroceryListModel model;
  final void Function(String?) onSelected;

  const CategoryTab({super.key, required this.model, required this.onSelected});

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

class SettingsTab extends StatefulWidget {
  final GroceryListModel model;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsTab({
    super.key,
    required this.model,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  List<String> _savedNames = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNames();
  }

  Future<void> _loadSavedNames() async {
    setState(() => _loading = true);
    final names = await widget.model.savedListNames();
    setState(() {
      _savedNames = names;
      _loading = false;
    });
  }

  Future<void> _onSaveTapped() async {
    if (widget.model.items.isEmpty) return;
    final name = await _promptForName();
    if (name == null || name.isEmpty) return;

    if (_savedNames.contains(name)) {
      if (!mounted) return;
      final over = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Overwrite saved list?'),
          content: Text(
            'A saved list named "$name" already exists. Overwrite?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );
      if (over != true) return;
    }

    await widget.model.saveNamedList(name, clearAfterSave: true);
    if (!mounted) return;
    await _loadSavedNames();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('List saved and cleared')));
  }

  Future<void> _onLoadTapped() async {
    if (_savedNames.isEmpty) return;

    if (widget.model.items.isNotEmpty) {
      if (!mounted) return;
      final choice = await showDialog<String?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save current list?'),
          content: const Text(
            'Do you want to save your current list before loading another saved list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('no'),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('yes'),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      if (choice == 'yes') {
        final name = await _promptForName();
        if (name == null || name.isEmpty) return;
        await widget.model.saveNamedList(name, clearAfterSave: true);
        if (!mounted) return;
        await _loadSavedNames();
        if (!mounted) return;
      }
    }

    if (!mounted) return;
    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Load saved list'),
        children: _savedNames.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No saved lists'),
                ),
              ]
            : _savedNames
                  .map(
                    (n) => SimpleDialogOption(
                      onPressed: () => Navigator.of(ctx).pop(n),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(n),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await widget.model.removeSavedList(n);
                              await _loadSavedNames();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
      ),
    );

    if (selected == null) return;
    await widget.model.loadNamedList(selected);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved list loaded')));
    setState(() {});
  }

  Future<String?> _promptForName() async {
    final ctl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save current list'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(labelText: 'List name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted) return null;
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Dark mode'),
          value: isDark,
          onChanged: (v) =>
              widget.onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light),
        ),
        const Divider(),
        Text('Lists', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Save current list'),
          subtitle: const Text('Save the current grocery list to load later'),
          enabled: widget.model.items.isNotEmpty,
          onTap: _onSaveTapped,
          leading: const Icon(Icons.save),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Load saved list'),
          subtitle: _loading
              ? const Text('Loading...')
              : Text('${_savedNames.length} saved lists'),
          enabled: _savedNames.isNotEmpty,
          onTap: _onLoadTapped,
          leading: const Icon(Icons.folder_open),
        ),
      ],
    );
  }
}
