class GroceryItem {
  final String id;
  final String name;
  final int quantity;
  final String category;
  final String? notes;
  final bool priority;
  final bool purchased;
  final DateTime createdAt;

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.notes,
    this.priority = false,
    this.purchased = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  GroceryItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? category,
    String? notes,
    bool? priority,
    bool? purchased,
    DateTime? createdAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      purchased: purchased ?? this.purchased,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'category': category,
    'notes': notes,
    'priority': priority,
    'purchased': purchased,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GroceryItem.fromJson(Map<String, dynamic> j) => GroceryItem(
    id: j['id'] as String,
    name: j['name'] as String,
    quantity: j['quantity'] as int,
    category: j['category'] as String,
    notes: j['notes'] as String?,
    priority: j['priority'] as bool? ?? false,
    purchased: j['purchased'] as bool? ?? false,
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}
