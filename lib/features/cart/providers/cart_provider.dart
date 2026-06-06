import 'package:flutter/foundation.dart';
import 'package:developer_task/core/models/cart_item.dart';
import 'package:developer_task/core/models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.values.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.values.fold(0, (total, item) => total + item.lineTotal);

  bool get hasItems => _items.isNotEmpty;

  /// Returns error message when add fails, null on success.
  String? addProduct(Product product, {int quantity = 1}) {
    if (!product.isInStock) return '${product.name} is out of stock';

    final existing = _items[product.id];
    final newQty = (existing?.quantity ?? 0) + quantity;
    if (newQty > product.stock) {
      return 'Only ${product.stock} of ${product.name} left';
    }

    if (existing == null) {
      _items[product.id] = CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
    } else {
      _items[product.id] = existing.copyWith(quantity: newQty);
    }
    notifyListeners();
    return null;
  }

  /// Returns error message when update fails, null on success.
  String? updateQuantity(String productId, int quantity, {required int maxStock}) {
    if (!_items.containsKey(productId)) return null;
    if (quantity <= 0) {
      _items.remove(productId);
      notifyListeners();
      return null;
    }
    if (quantity > maxStock) {
      return maxStock > 0 ? 'Only $maxStock left in stock' : 'Out of stock';
    }
    _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    notifyListeners();
    return null;
  }

  void syncWithProducts(List<Product> products) {
    final stockById = {for (final p in products) p.id: p.stock};
    var changed = false;

    for (final entry in _items.entries.toList()) {
      final maxStock = stockById[entry.key] ?? 0;
      if (maxStock <= 0) {
        _items.remove(entry.key);
        changed = true;
      } else if (entry.value.quantity > maxStock) {
        _items[entry.key] = entry.value.copyWith(quantity: maxStock);
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
