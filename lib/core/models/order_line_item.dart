class OrderLineItem {
  const OrderLineItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;

  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['qty'] as num?)?.toInt() ?? 1,
    );
  }
}
