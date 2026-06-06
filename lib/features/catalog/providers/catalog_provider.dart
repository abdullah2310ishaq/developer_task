import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/shared/data/services/firestore_products_service.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._productsService);

  final FirestoreProductsService _productsService;

  List<Product> products = [];
  String selectedCategory = 'All';
  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<Product>>? _subscription;

  List<String> get categories {
    final set = <String>{};
    for (final product in products) {
      if (product.isActive) set.add(product.category);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<Product> get filteredProducts {
    if (selectedCategory == 'All') {
      return products.where((p) => p.isActive).toList();
    }
    return products
        .where((p) => p.isActive && p.category == selectedCategory)
        .toList();
  }

  Product? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void startListening() {
    if (_subscription != null) return;
    if (products.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    _subscription = _productsService.watchAllProducts().listen(
      (list) {
        products = list;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Could not load menu';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    products = [];
    selectedCategory = 'All';
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
