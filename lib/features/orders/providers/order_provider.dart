import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show StripeException;
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/enums/payment_types.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/features/auth/models/app_user.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/shared/data/services/firestore_notifications_service.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';
import 'package:developer_task/shared/data/services/stripe_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(
    this._ordersService,
    this._stripeService,
    this._notificationsDb,
  );

  final FirestoreOrdersService _ordersService;
  final StripeService _stripeService;
  final FirestoreNotificationsService _notificationsDb;

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
    userOrders = [];
    notifyListeners();
  }

  void trackOrder(String orderId, String _) {
    if (_activeUserId == null) return;
    _trackSub?.cancel();
    _trackSub = _ordersService.watchOrder(orderId).listen((order) {
      trackedOrder = order;
      notifyListeners();
    });
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

      await _notificationsDb.addNotification(
        userId: user.uid,
        title: 'Order placed',
        body: 'We received your order. Waiting for kitchen to accept.',
        orderId: orderId,
      );

      cart.clear();
      lastCreatedOrderId = orderId;
      checkoutState = PaymentCheckoutSucceeded(method: selectedMethod);
      return orderId;
    } on InsufficientStockException catch (e) {
      checkoutState = PaymentCheckoutFailed(
        message: e.toString(),
        method: selectedMethod,
      );
      errorMessage = e.toString();
      return null;
    } catch (e) {
      final message = e is StripeException
          ? (e.error.localizedMessage ?? 'Payment cancelled')
          : e.toString().contains('STRIPE') || e.toString().contains('Stripe')
              ? 'Stripe payment failed'
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
