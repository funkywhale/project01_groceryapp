import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class GroceryTile extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePurchased;

  const GroceryTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePurchased,
  });

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
        'Qty: ${item.quantity}            ${item.notes != null && item.notes!.isNotEmpty ? ' • ${item.notes}' : ''}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (item.price != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                '\$${item.price!.toStringAsFixed(2)}',
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (item.priority)
                const Tooltip(
                  message: 'Priority',
                  child: Icon(
                    Icons.priority_high,
                    color: Colors.orangeAccent,
                    size: 20,
                  ),
                ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
