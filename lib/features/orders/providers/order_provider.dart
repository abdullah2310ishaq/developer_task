import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/enums/payment_types.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/features/auth/models/app_user.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';
import 'package:developer_task/shared/data/services/stripe_service.dart';

typedef TrackedStatusCallback = void Function(
  AppOrder order,
  OrderTrackingStatus? previousStatus,
);

typedef OrderPlacedCallback = void Function(String orderId);

class OrderProvider extends ChangeNotifier {
  OrderProvider(
    this._ordersService,
    this._stripeService, {
    this.onTrackedStatusChange,
    this.onOrderPlaced,
  });

  final FirestoreOrdersService _ordersService;
  final StripeService _stripeService;
  final TrackedStatusCallback? onTrackedStatusChange;
  final OrderPlacedCallback? onOrderPlaced;

  List<AppOrder> userOrders = [];
  AppOrder? trackedOrder;
  PaymentMethod selectedMethod = const PaymentCashOnDelivery();
  PaymentCheckoutState checkoutState = const PaymentCheckoutIdle();
  bool isLoading = false;
  bool isPlacingOrder = false;
  String? errorMessage;
  String? lastCreatedOrderId;

  StreamSubscription<List<AppOrder>>? _ordersSub;
  StreamSubscription<AppOrder?>? _trackSub;
  String? _activeUserId;
  OrderTrackingStatus? _trackedPreviousStatus;

  void startUserOrders(String userId) {
    if (_activeUserId == userId && _ordersSub != null) return;

    stopUserOrders();
    _activeUserId = userId;
    isLoading = true;
    notifyListeners();

    _ordersSub = _ordersService.watchUserOrders(userId).listen(
      (list) {
        userOrders = list;
        isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Could not load orders';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopUserOrders() {
    _activeUserId = null;
    _ordersSub?.cancel();
    _ordersSub = null;
    _trackSub?.cancel();
    _trackSub = null;
    trackedOrder = null;
    _trackedPreviousStatus = null;
    userOrders = [];
    notifyListeners();
  }

  void trackOrder(String orderId, String userId) {
    _activeUserId ??= userId;
    _trackSub?.cancel();
    _trackedPreviousStatus = null;

    _trackSub = _ordersService.watchOrder(orderId).listen(
      (order) {
        if (order == null) {
          trackedOrder = null;
          _trackedPreviousStatus = null;
          notifyListeners();
          return;
        }

        final previous = _trackedPreviousStatus;
        trackedOrder = order;

        if (previous != null && previous.stepIndex != order.status.stepIndex) {
          onTrackedStatusChange?.call(order, previous);
        }

        _trackedPreviousStatus = order.status;
        notifyListeners();
      },
      onError: (_) {
        errorMessage = 'Could not track order';
        notifyListeners();
      },
    );
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedMethod = method;
    notifyListeners();
  }

  bool get usesStripeInAppPayment =>
      selectedMethod is PaymentStripe && _stripeService.canPayInApp;

  bool get usesStripePaymentLink =>
      selectedMethod is PaymentStripe &&
      !_stripeService.canPayInApp &&
      _stripeService.hasPaymentLink;

  Future<bool> openStripePaymentLink() => _stripeService.openPaymentLink();

  Future<String?> placeOrder({
    required AppUser user,
    required CartProvider cart,
    bool stripePaymentConfirmed = false,
  }) async {
    if (!cart.hasItems) {
      errorMessage = 'Cart is empty';
      notifyListeners();
      return null;
    }

    isPlacingOrder = true;
    errorMessage = null;
    checkoutState = PaymentCheckoutProcessing(method: selectedMethod);
    notifyListeners();

    try {
      await _ordersService.validateCartStock(cart.items);

      PaymentRecordStatus paymentStatus = const PaymentPending();

      if (selectedMethod is PaymentStripe) {
        if (_stripeService.canPayInApp) {
          await _stripeService.payCartAmount(amount: cart.subtotal);
          paymentStatus = const PaymentPaid();
        } else if (_stripeService.hasPaymentLink) {
          if (!stripePaymentConfirmed) {
            errorMessage = 'Complete Stripe checkout first';
            return null;
          }
          paymentStatus = const PaymentPaid();
        } else {
          throw StateError(
            'Add STRIPE_SECRET_KEY, STRIPE_PAYMENT_INTENT_URL, or STRIPE_PAYMENT_LINK_URL',
          );
        }
      }

      final orderId = await _ordersService.createOrder(
        userId: user.uid,
        customerName: user.displayName ?? 'Customer',
        phone: user.phone ?? '',
        address: user.address ?? '',
        items: cart.items,
        total: cart.subtotal,
        paymentMethod: selectedMethod,
        paymentStatus: paymentStatus,
      );

      cart.clear();
      lastCreatedOrderId = orderId;
      checkoutState = PaymentCheckoutSucceeded(method: selectedMethod);
      onOrderPlaced?.call(orderId);
      return orderId;
    } on InsufficientStockException catch (e) {
      checkoutState = PaymentCheckoutFailed(
        message: e.toString(),
        method: selectedMethod,
      );
      errorMessage = e.toString();
      return null;
    } catch (e) {
      final message = selectedMethod is PaymentStripe
          ? _stripeService.mapPaymentError(e)
          : 'Payment failed';
      checkoutState = PaymentCheckoutFailed(
        message: message,
        method: selectedMethod,
      );
      errorMessage = message;
      return null;
    } finally {
      isPlacingOrder = false;
      notifyListeners();
    }
  }

  Future<bool> confirmReceived(String orderId) async {
    final order = trackedOrder;
    if (order == null || order.status is! OrderOutForDelivery) return false;

    isLoading = true;
    notifyListeners();
    try {
      await _ordersService.confirmDelivered(orderId);
      return true;
    } catch (e) {
      errorMessage = 'Could not confirm delivery';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetCheckout() {
    checkoutState = const PaymentCheckoutIdle();
    notifyListeners();
  }

  @override
  void dispose() {
    stopUserOrders();
    super.dispose();
  }
}
