import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePurchased;

  const GroceryTile({
    Key? key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePurchased,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = item.purchased
        ? const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          )
        : const TextStyle();

    return ListTile(
      leading: Checkbox(
        value: item.purchased,
        onChanged: (v) => onTogglePurchased(),
      ),
      title: Text(item.name, style: textStyle),
      subtitle: Text(
        '${item.quantity} • ${item.category}${item.notes != null && item.notes!.isNotEmpty ? ' • ${item.notes}' : ''}',
      ),
      trailing: Wrap(
        spacing: 8,
        children: [
          if (item.priority)
            const Chip(
              label: Text('Need Today'),
              backgroundColor: Colors.orangeAccent,
            ),
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
      onTap: onEdit,
    );
  }
}
