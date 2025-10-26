import 'package:flutter/material.dart';
import '../models/grocery_list_model.dart';
import '../models/grocery_item.dart';

class AddEditScreen extends StatefulWidget {
  final GroceryListModel model;
  final GroceryItem? item;

  const AddEditScreen({Key? key, required this.model, this.item})
    : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _qtyCtl = TextEditingController(text: '1');
  final _notesCtl = TextEditingController();
  String _category = 'Produce';
  bool _priority = false;

  static const List<String> _categories = [
    'Produce',
    'Dairy',
    'Bakery',
    'Snacks',
    'Beverages',
    'Household',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final it = widget.item!;
      _nameCtl.text = it.name;
      _qtyCtl.text = it.quantity.toString();
      _notesCtl.text = it.notes ?? '';
      _category = it.category;
      _priority = it.priority;
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _qtyCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtl.text.trim();
    final qty = int.tryParse(_qtyCtl.text) ?? 1;

    if (widget.item == null) {
      widget.model.createAndAdd(
        name: name,
        quantity: qty,
        category: _category,
        notes: _notesCtl.text.trim(),
        priority: _priority,
      );
    } else {
      final updated = widget.item!.copyWith(
        name: name,
        quantity: qty,
        category: _category,
        notes: _notesCtl.text.trim(),
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
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyCtl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Category'),
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
          ),
        ),
      ),
    );
  }
}
