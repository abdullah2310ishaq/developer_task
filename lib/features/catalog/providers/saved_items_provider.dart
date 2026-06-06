import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/features/catalog/data/firestore_saved_items_service.dart';

class SavedItemsProvider extends ChangeNotifier {
  SavedItemsProvider(this._service);

  final FirestoreSavedItemsService _service;

  Set<String> savedIds = {};
  bool isLoading = false;
  String? errorMessage;
  StreamSubscription<Set<String>>? _sub;
  String? _activeUserId;

  int get count => savedIds.length;

  bool isSaved(String productId) => savedIds.contains(productId);

  List<Product> savedProducts(List<Product> catalog) {
    return catalog.where((p) => savedIds.contains(p.id) && p.isActive).toList();
  }

  void startListening(String userId) {
    if (_activeUserId == userId && _sub != null) return;

    stopListening();
    _activeUserId = userId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _sub = _service.watchSavedProductIds(userId).listen(
      (ids) {
        savedIds = ids;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        savedIds = {};
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _activeUserId = null;
    _sub?.cancel();
    _sub = null;
    savedIds = {};
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> toggle(String productId) async {
    final userId = _activeUserId;
    if (userId == null) return false;

    errorMessage = null;
    try {
      if (isSaved(productId)) {
        await _service.removeItem(userId, productId);
      } else {
        await _service.saveItem(userId, productId);
      }
      return true;
    } catch (_) {
      errorMessage = 'Could not update saved item';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
