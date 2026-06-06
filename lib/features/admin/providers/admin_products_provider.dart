import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/shared/data/services/cloudinary_service.dart';
import 'package:developer_task/shared/data/services/firestore_products_service.dart';

class AdminProductsProvider extends ChangeNotifier {
  AdminProductsProvider(this._productsService, this._cloudinaryService);

  final FirestoreProductsService _productsService;
  final CloudinaryService _cloudinaryService;

  List<Product> products = [];
  String selectedCategory = 'All';
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  List<String> get categories {
    final set = <String>{};
    for (final product in products) {
      set.add(product.category);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<Product> get filteredProducts {
    if (selectedCategory == 'All') return products;
    return products.where((p) => p.category == selectedCategory).toList();
  }

  StreamSubscription<List<Product>>? _subscription;

  void startListening() {
    if (_subscription != null) return;
    if (products.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    _subscription = _productsService.watchAllProducts().listen(
      (list) {
        products = list.where((p) => p.isActive).toList();
        if (selectedCategory != 'All' &&
            !products.any((p) => p.category == selectedCategory)) {
          selectedCategory = 'All';
        }
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Could not load products';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> saveProduct({
    Product? existing,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required File? imageFile,
    String? existingImageUrl,
  }) async {
    if (name.trim().isEmpty || price <= 0) {
      errorMessage = 'Name and valid price required';
      notifyListeners();
      return false;
    }
    if (stock < 0) {
      errorMessage = 'Stock cannot be negative';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      String imageUrl = existingImageUrl ?? '';
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(imageFile);
      }
      if (imageUrl.isEmpty) {
        errorMessage = 'Pick a food image';
        return false;
      }

      if (existing == null) {
        await _productsService.createProduct(
          Product(
            id: '',
            name: name.trim(),
            description: description.trim(),
            price: price,
            imageUrl: imageUrl,
            category: category.trim().isEmpty ? 'General' : category.trim(),
            stock: stock,
          ),
        );
      } else {
        await _productsService.updateProduct(
          existing.copyWith(
            name: name.trim(),
            description: description.trim(),
            price: price,
            imageUrl: imageUrl,
            category: category.trim().isEmpty ? 'General' : category.trim(),
            stock: stock,
          ),
        );
      }
      return true;
    } catch (e) {
      errorMessage = 'Save failed — check Cloudinary preset';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  Future<bool> removeProduct(String productId) async {
    try {
      await _productsService.deleteProduct(productId);
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
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
