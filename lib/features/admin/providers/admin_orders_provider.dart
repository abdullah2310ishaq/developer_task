import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';

class AdminOrdersProvider extends ChangeNotifier {
  AdminOrdersProvider(this._ordersService);

  final FirestoreOrdersService _ordersService;

  List<AppOrder> orders = [];
  List<AppOrder> historyOrders = [];
  bool isLoading = false;
  String? errorMessage;
  final Set<String> _updatingIds = {};

  StreamSubscription<List<AppOrder>>? _subscription;
  String? _activeAdminId;

  int get pendingCount => orders.where((o) => o.status is OrderPending).length;
  int get preparingCount => orders.where((o) => o.status is OrderPreparing).length;
  int get dispatchedCount => orders.where((o) => o.status is OrderOutForDelivery).length;

  AppOrder? orderById(String id) {
    for (final order in [...orders, ...historyOrders]) {
      if (order.id == id) return order;
    }
    return null;
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  void startListening(String adminUserId) {
    if (_activeAdminId == adminUserId && _subscription != null) return;

    stopListening();
    _activeAdminId = adminUserId;
    isLoading = true;
    notifyListeners();

    _subscription = _ordersService.watchAllOrders().listen(
      (list) {
        orders = list.where((o) => o.status is! OrderDelivered).toList();
        historyOrders = list.where((o) => o.status is OrderDelivered).toList();
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Could not load orders';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _activeAdminId = null;
    _subscription?.cancel();
    _subscription = null;
    orders = [];
    historyOrders = [];
    notifyListeners();
  }

  bool isUpdating(String orderId) => _updatingIds.contains(orderId);

  Future<bool> acceptOrder(String orderId) async {
    final fresh = await _resolveOrder(orderId);
    if (fresh == null) return false;
    if (fresh.status is! OrderPending) {
      errorMessage = 'Order is no longer pending';
      notifyListeners();
      return false;
    }
    return _updateStatus(orderId, const OrderPreparing());
  }

  Future<bool> dispatchOrder(
    String orderId, {
    required String riderName,
    required String riderPhone,
  }) async {
    final name = riderName.trim();
    final phone = _normalizePhone(riderPhone);
    if (name.isEmpty || phone.length < 10) {
      errorMessage = 'Enter rider name and a valid contact number';
      notifyListeners();
      return false;
    }

    final fresh = await _resolveOrder(orderId);
    if (fresh == null) return false;

    if (fresh.status is OrderOutForDelivery) {
      errorMessage = null;
      notifyListeners();
      return true;
    }

    if (fresh.status is! OrderPreparing) {
      errorMessage = fresh.status is OrderPending
          ? 'Accept the order before dispatching'
          : 'This order cannot be dispatched';
      notifyListeners();
      return false;
    }

    _updatingIds.add(orderId);
    errorMessage = null;
    notifyListeners();

    try {
      await _ordersService.dispatchOrder(
        orderId: orderId,
        riderName: name,
        riderPhone: phone,
      );
      errorMessage = null;
      return true;
    } on FirebaseException catch (e) {
      errorMessage = e.code == 'permission-denied'
          ? 'Firestore blocked dispatch — check Firebase rules'
          : 'Could not dispatch rider (${e.code})';
      return false;
    } catch (e) {
      errorMessage = 'Could not dispatch rider';
      return false;
    } finally {
      _updatingIds.remove(orderId);
      notifyListeners();
    }
  }

  Future<AppOrder?> _resolveOrder(String orderId) async {
    final cached = orderById(orderId);
    if (cached != null) return cached;

    try {
      final fresh = await _ordersService.fetchOrder(orderId);
      if (fresh == null) {
        errorMessage = 'Order not found';
        notifyListeners();
      }
      return fresh;
    } catch (_) {
      errorMessage = 'Could not load order';
      notifyListeners();
      return null;
    }
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('92') && digits.length == 12) {
      return '0${digits.substring(2)}';
    }
    return digits;
  }

  Future<bool> _updateStatus(String orderId, OrderTrackingStatus status) async {
    _updatingIds.add(orderId);
    errorMessage = null;
    notifyListeners();

    try {
      await _ordersService.updateOrderStatus(orderId, status);
      errorMessage = null;
      return true;
    } on FirebaseException catch (e) {
      errorMessage = e.code == 'permission-denied'
          ? 'Firestore blocked update — check Firebase rules'
          : 'Status update failed (${e.code})';
      return false;
    } catch (e) {
      errorMessage = 'Status update failed';
      return false;
    } finally {
      _updatingIds.remove(orderId);
      notifyListeners();
    }
  }

  String actionLabel(OrderTrackingStatus status) {
    return switch (status) {
      OrderPending() => 'Accept order',
      OrderPreparing() => 'Dispatch rider',
      OrderOutForDelivery() => 'Waiting for customer',
      OrderDelivered() => 'Done',
    };
  }

  bool canAdvance(OrderTrackingStatus status) => status is! OrderOutForDelivery;

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
