class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.stock = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final int stock;
  final bool isActive;

  bool get isInStock => isActive && stock > 0;

  String get stockLabel =>
      isInStock ? '$stock left' : 'Out of stock';

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'isActive': isActive,
    };
  }

  Product copyWith({
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    int? stock,
    bool? isActive,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
    );
  }
}
