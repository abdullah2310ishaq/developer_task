import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/shared/data/services/firestore_notifications_service.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

class AdminOrdersProvider extends ChangeNotifier {
  AdminOrdersProvider(
    this._ordersService,
    this._notificationService,
    this._notificationsDb,
  );

  final FirestoreOrdersService _ordersService;
  final NotificationService _notificationService;
  final FirestoreNotificationsService _notificationsDb;

  List<AppOrder> orders = [];
  List<AppOrder> historyOrders = [];
  bool isLoading = false;
  String? errorMessage;
  final Set<String> _updatingIds = {};

  StreamSubscription<List<AppOrder>>? _subscription;
  String? _activeAdminId;
  bool _seeded = false;
  final Set<String> _knownOrderIds = {};
  final Map<String, OrderTrackingStatus> _lastStatuses = {};

  int get pendingCount => orders.where((o) => o.status is OrderPending).length;
  int get preparingCount => orders.where((o) => o.status is OrderPreparing).length;
  int get dispatchedCount => orders.where((o) => o.status is OrderOutForDelivery).length;

  AppOrder? orderById(String id) {
    for (final order in [...orders, ...historyOrders]) {
      if (order.id == id) return order;
    }
    return null;
  }

  void startListening(String adminUserId) {
    if (_activeAdminId == adminUserId && _subscription != null) return;

    stopListening();
    _activeAdminId = adminUserId;
    _seeded = false;
    isLoading = true;
    notifyListeners();

    _subscription = _ordersService.watchAllOrders().listen(
      (list) async {
        if (!_seeded) {
          for (final order in list) {
            _knownOrderIds.add(order.id);
            _lastStatuses[order.id] = order.status;
          }
          _seeded = true;
        } else {
          for (final order in list) {
            final isNew = !_knownOrderIds.contains(order.id);
            if (isNew && order.status is OrderPending) {
              await _notifyAdmin(
                title: 'New order',
                body:
                    '${order.customerName ?? 'Customer'} · ${order.itemCount} items · Rs ${order.total.toStringAsFixed(0)}',
                orderId: order.id,
              );
            }

            final previous = _lastStatuses[order.id];
            if (previous != null &&
                order.status is OrderDelivered &&
                previous is! OrderDelivered) {
              await _notifyAdmin(
                title: 'Order received',
                body: '${order.customerName ?? 'Customer'} confirmed delivery',
                orderId: order.id,
              );
            }

            _knownOrderIds.add(order.id);
            _lastStatuses[order.id] = order.status;
          }
        }

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
    _seeded = false;
    _knownOrderIds.clear();
    _lastStatuses.clear();
    _subscription?.cancel();
    _subscription = null;
    orders = [];
    historyOrders = [];
    notifyListeners();
  }

  Future<void> _notifyAdmin({
    required String title,
    required String body,
    required String orderId,
  }) async {
    final adminId = _activeAdminId;
    if (adminId == null) return;

    await _notificationService.showOrderUpdate(
      id: orderId.hashCode,
      title: title,
      body: body,
    );
    await _notificationsDb.addNotification(
      userId: adminId,
      title: title,
      body: body,
      orderId: orderId,
    );
  }

  bool isUpdating(String orderId) => _updatingIds.contains(orderId);

  Future<bool> acceptOrder(AppOrder order) async {
    if (order.status is! OrderPending) return false;

    final ok = await _updateStatus(order.id, const OrderPreparing());
    if (ok) {
      await _notifyCustomer(
        order: order,
        title: 'Order accepted',
        body: 'Kitchen is preparing your order',
      );
    }
    return ok;
  }

  Future<bool> dispatchOrder(
    AppOrder order, {
    required String riderName,
    required String riderPhone,
  }) async {
    if (order.status is! OrderPreparing) return false;
    if (riderName.trim().isEmpty || riderPhone.trim().length < 11) {
      errorMessage = 'Enter rider name and 11-digit contact';
      notifyListeners();
      return false;
    }

    _updatingIds.add(order.id);
    notifyListeners();

    try {
      await _ordersService.dispatchOrder(
        orderId: order.id,
        riderName: riderName,
        riderPhone: riderPhone,
      );
      await _notifyCustomer(
        order: order,
        title: 'Order on the way',
        body: 'Rider $riderName is heading to you · $riderPhone',
      );
      return true;
    } catch (e) {
      errorMessage = 'Could not dispatch rider';
      return false;
    } finally {
      _updatingIds.remove(order.id);
      notifyListeners();
    }
  }

  Future<void> _notifyCustomer({
    required AppOrder order,
    required String title,
    required String body,
  }) async {
    await _notificationsDb.addNotification(
      userId: order.userId,
      title: title,
      body: body,
      orderId: order.id,
    );
  }

  Future<bool> _updateStatus(String orderId, OrderTrackingStatus status) async {
    _updatingIds.add(orderId);
    notifyListeners();

    try {
      await _ordersService.updateOrderStatus(orderId, status);
      return true;
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
