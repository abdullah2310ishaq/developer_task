import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._ordersService, this._local);

  final FirestoreOrdersService _ordersService;
  final NotificationService _local;

  List<Map<String, dynamic>> items = [];
  String? streamError;
  StreamSubscription<List<AppOrder>>? _orderSub;
  String? _activeUserId;
  bool _isAdmin = false;
  bool _seeded = false;
  final Map<String, OrderTrackingStatus> _lastStatuses = {};
  final Set<String> _knownOrderIds = {};
  final Set<String> _pingedKeys = {};

  int get unreadCount => items.where((n) => n['read'] != true).length;

  bool get hasUnread => unreadCount > 0;

  bool get isListening => _activeUserId != null;

  void ensureListening(String userId, {required bool isAdmin}) {
    if (_activeUserId == userId && _isAdmin == isAdmin && _orderSub != null) return;
    startListening(userId, isAdmin: isAdmin);
  }

  void startListening(String userId, {required bool isAdmin}) {
    if (_activeUserId == userId && _isAdmin == isAdmin && _orderSub != null) return;

    stopListening(keepItems: true);
    _activeUserId = userId;
    _isAdmin = isAdmin;
    _seeded = false;
    streamError = null;
    _lastStatuses.clear();
    _knownOrderIds.clear();

    _subscribeToOrders();
  }

  void _subscribeToOrders() {
    final userId = _activeUserId;
    if (userId == null) return;

    _orderSub?.cancel();
    final stream = _isAdmin
        ? _ordersService.watchAllOrders()
        : _ordersService.watchUserOrders(userId);

    _orderSub = stream.listen(
      _onOrdersUpdate,
      onError: (error) {
        streamError = 'Order updates unavailable';
        if (kDebugMode) {
          debugPrint('NotificationProvider stream error: $error');
        }
        notifyListeners();
      },
    );
  }

  void retryListening() {
    if (_activeUserId == null) return;
    streamError = null;
    _seeded = false;
    _subscribeToOrders();
    notifyListeners();
  }

  void pushFromOrderStatus(AppOrder order, {OrderTrackingStatus? previousStatus}) {
    if (_isAdmin) return;

    final previous = previousStatus ?? _lastStatuses[order.id];
    if (previous != null && previous.stepIndex == order.status.stepIndex) return;

    if (previousStatus == null && !_knownOrderIds.contains(order.id)) {
      pushOrderPlaced(order.id);
      return;
    }

    final update = _userStatusMessage(order.status, order);
    if (update != null) {
      _push(
        key: 'user_${order.id}_${order.status.stepIndex}',
        orderId: order.id,
        title: update.$1,
        body: update.$2,
      );
    }

    _knownOrderIds.add(order.id);
    _lastStatuses[order.id] = order.status;
    notifyListeners();
  }

  void pushOrderPlaced(String orderId) {
    _push(
      key: 'user_placed_$orderId',
      orderId: orderId,
      title: 'Order placed',
      body: 'Waiting for kitchen to accept your order',
    );
    _knownOrderIds.add(orderId);
    _lastStatuses[orderId] = const OrderPending();
    notifyListeners();
  }

  void _onOrdersUpdate(List<AppOrder> orders) {
    if (_activeUserId == null) return;

    streamError = null;

    if (!_seeded) {
      for (final order in orders) {
        _knownOrderIds.add(order.id);
        _lastStatuses[order.id] = order.status;
      }
      _seeded = true;
      notifyListeners();
      return;
    }

    for (final order in orders) {
      final isNew = !_knownOrderIds.contains(order.id);
      final previous = _lastStatuses[order.id];

      if (_isAdmin) {
        if (isNew && order.status is OrderPending) {
          _push(
            key: 'admin_new_${order.id}',
            orderId: order.id,
            title: 'New order',
            body:
                '${order.customerName ?? 'Customer'} · ${order.itemCount} items · Rs ${order.total.toStringAsFixed(0)}',
          );
        } else if (previous != null &&
            order.status is OrderDelivered &&
            previous is! OrderDelivered) {
          _push(
            key: 'admin_done_${order.id}',
            orderId: order.id,
            title: 'Order received',
            body: '${order.customerName ?? 'Customer'} confirmed delivery',
          );
        }
      } else {
        if (isNew) {
          pushOrderPlaced(order.id);
          continue;
        }
        if (previous != null && previous.stepIndex != order.status.stepIndex) {
          final update = _userStatusMessage(order.status, order);
          if (update != null) {
            _push(
              key: 'user_${order.id}_${order.status.stepIndex}',
              orderId: order.id,
              title: update.$1,
              body: update.$2,
            );
          }
        }
      }

      _knownOrderIds.add(order.id);
      _lastStatuses[order.id] = order.status;
    }

    notifyListeners();
  }

  (String, String)? _userStatusMessage(OrderTrackingStatus status, AppOrder order) {
    return switch (status) {
      OrderPreparing() => ('Order accepted', 'Kitchen is preparing your food'),
      OrderOutForDelivery() => (
          'Order dispatched',
          order.riderName != null
              ? 'Rider ${order.riderName} is on the way'
              : 'Your order is on the way',
        ),
      OrderDelivered() => ('Order delivered', 'Enjoy your meal!'),
      OrderPending() => null,
    };
  }

  void _push({
    required String key,
    required String orderId,
    required String title,
    required String body,
  }) {
    if (_pingedKeys.contains(key)) return;
    _pingedKeys.add(key);

    items.insert(0, {
      'id': key,
      'orderId': orderId,
      'title': title,
      'body': body,
      'read': false,
      'createdAt': Timestamp.now(),
    });

    unawaited(
      _local.showOrderUpdate(
        id: key.hashCode,
        title: title,
        body: body,
      ),
    );
  }

  void stopListening({bool keepItems = false}) {
    _activeUserId = null;
    _isAdmin = false;
    _seeded = false;
    streamError = null;
    _lastStatuses.clear();
    _knownOrderIds.clear();
    if (!keepItems) {
      _pingedKeys.clear();
      items = [];
    }
    _orderSub?.cancel();
    _orderSub = null;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = items.indexWhere((n) => n['id'] == notificationId);
    if (index == -1) return;
    items[index] = {...items[index], 'read': true};
    notifyListeners();
  }

  Future<void> markAsUnread(String notificationId) async {
    final index = items.indexWhere((n) => n['id'] == notificationId);
    if (index == -1) return;
    items[index] = {...items[index], 'read': false};
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    items = items.map((n) => {...n, 'read': true}).toList();
    notifyListeners();
  }

  Future<bool> requestPermission() => _local.requestPermission();

  Future<bool> areNotificationsEnabled() => _local.areNotificationsEnabled();

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
