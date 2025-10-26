import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';
import '../models/grocery_item.dart';
import '../models/grocery_catalog.dart';

class AddEditScreen extends StatefulWidget {
  final GroceryListModel model;
  final GroceryItem? item;

  const AddEditScreen({super.key, required this.model, this.item});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtl = TextEditingController();
  String? _selectedCategory;
  String? _selectedItemName;
  bool _includePrice = false;
  int? _selectedDollars;
  int _selectedCents = 0;
  int _selectedQty = 1;
  bool _priority = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final it = widget.item!;
      _selectedCategory = it.category;
      _selectedItemName = it.name;
      if (it.price != null) {
        _includePrice = true;
        final p = it.price!.clamp(0, double.infinity);
        int dollars = p.floor();
        int cents = ((p - dollars) * 100).round();
        if (cents >= 100) {
          dollars += 1;
          cents = 0;
        }
        _selectedDollars = dollars.clamp(1, 99);
        _selectedCents = _closestAllowedCents(cents);
      } else {
        _includePrice = false;
        _selectedDollars = null;
        _selectedCents = 0;
      }
      _selectedQty = it.quantity;
      _notesCtl.text = it.notes ?? '';
      _priority = it.priority;
    } else {
      _selectedCategory = null;
      _selectedItemName = null;
      _includePrice = false;
      _selectedDollars = null;
      _selectedCents = 0;
      _selectedQty = 1;
      _priority = false;
    }
  }

  @override
  void dispose() {
    _notesCtl.dispose();
    super.dispose();
  }

  int _closestAllowedCents(int cents) {
    const allowed = [0, 49, 79, 99];
    int best = allowed.first;
    int bestDiff = (cents - best).abs();
    for (final a in allowed.skip(1)) {
      final d = (cents - a).abs();
      if (d < bestDiff) {
        best = a;
        bestDiff = d;
      }
    }
    return best;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _selectedItemName!;
    final qty = _selectedQty;
    final String category = _selectedCategory!;
    final double? price = _includePrice && _selectedDollars != null
        ? _selectedDollars! + (_selectedCents / 100.0)
        : null;

    if (widget.item == null) {
      widget.model.createAndAdd(
        name: name,
        quantity: qty,
        category: category,
        notes: _notesCtl.text.trim(),
        priority: _priority,
        price: price,
      );
    } else {
      final updated = widget.item!.copyWith(
        name: name,
        quantity: qty,
        category: category,
        notes: _notesCtl.text.trim(),
        price: price,
        priority: _priority,
      );
      widget.model.updateItem(widget.item!.id, updated);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.item != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: GroceryCatalog.categories()
                    .map(
                      (c) => DropdownMenuItem<String>(value: c, child: Text(c)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v;
                    _selectedItemName = null;
                    _includePrice = false;
                    _selectedDollars = null;
                    _selectedCents = 0;
                    _selectedQty = 1;
                  });
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please select a category' : null,
              ),
              const SizedBox(height: 8),

              if (_selectedCategory != null)
                Builder(
                  builder: (context) {
                    final items = GroceryCatalog.itemsForCategory(
                      _selectedCategory!,
                    );
                    if (_selectedItemName != null &&
                        !items.contains(_selectedItemName)) {
                      items.add(_selectedItemName!);
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedItemName,
                      decoration: const InputDecoration(labelText: 'Item'),
                      items: items
                          .map(
                            (n) => DropdownMenuItem<String>(
                              value: n,
                              child: Text(n),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedItemName = v;
                          _includePrice = false;
                          _selectedDollars = null;
                          _selectedCents = 0;
                          _selectedQty = 1;
                        });
                      },
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please select an item'
                          : null,
                    );
                  },
                ),
              if (_selectedItemName != null) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Specify price'),
                  value: _includePrice,
                  onChanged: (v) {
                    setState(() {
                      _includePrice = v;
                      if (v) {
                        _selectedDollars ??= 1;
                        _selectedCents = _selectedCents;
                      } else {
                        _selectedDollars = null;
                        _selectedCents = 0;
                      }
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                if (_includePrice) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedDollars,
                          decoration: const InputDecoration(
                            labelText: 'Dollars',
                          ),
                          items: List<int>.generate(99, (i) => i)
                              .map(
                                (d) => DropdownMenuItem<int>(
                                  value: d,
                                  child: Text(d.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDollars = v),
                          validator: (v) =>
                              (_includePrice && (v == null || v < 0 || v > 99))
                              ? 'Select dollars'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedCents,
                          decoration: const InputDecoration(labelText: 'Cents'),
                          items: const [0, 49, 79, 99]
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c,
                                  child: Text(
                                    '.${c.toString().padLeft(2, '0')}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCents = v ?? 0),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedQty,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  items: GroceryCatalog.quantityOptions
                      .map(
                        (q) => DropdownMenuItem<int>(
                          value: q,
                          child: Text(q.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedQty = v ?? 1),
                  validator: (v) =>
                      (v == null || v <= 0) ? 'Please select a quantity' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesCtl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Need Today'),
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
