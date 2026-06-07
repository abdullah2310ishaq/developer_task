import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/config/env_config.dart';
import 'package:developer_task/features/admin/providers/admin_orders_provider.dart';
import 'package:developer_task/features/admin/providers/admin_products_provider.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/services/auth_service.dart';
import 'package:developer_task/features/auth/services/auth_user_service.dart';
import 'package:developer_task/features/auth/services/session_token_storage.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/catalog/data/firestore_saved_items_service.dart';
import 'package:developer_task/features/catalog/providers/catalog_provider.dart';
import 'package:developer_task/features/catalog/providers/saved_items_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/shared/data/services/cloudinary_service.dart';
import 'package:developer_task/shared/data/services/firestore_orders_service.dart';
import 'package:developer_task/shared/data/services/firestore_products_service.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';
import 'package:developer_task/shared/data/services/stripe_service.dart';

/// Wires shared services into feature providers — no UI or routes here.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(webClientId: EnvConfig.googleWebClientId);
    final authUserService = AuthUserService();
    final sessionTokenStorage = SessionTokenStorage();
    final productsService = FirestoreProductsService();
    final ordersService = FirestoreOrdersService();
    final cloudinaryService = CloudinaryService();
    final stripeService = StripeService();
    final notificationService = NotificationService();
    final notificationProvider = NotificationProvider(
      ordersService,
      notificationService,
    );
    final orderProvider = OrderProvider(
      ordersService,
      stripeService,
      onTrackedStatusChange: (order, previous) => notificationProvider
          .pushFromOrderStatus(order, previousStatus: previous),
      onOrderPlaced: notificationProvider.pushOrderPlaced,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(authService, authUserService, sessionTokenStorage),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AdminProductsProvider(productsService, cloudinaryService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminOrdersProvider(ordersService),
        ),
        ChangeNotifierProvider(create: (_) => CatalogProvider(productsService)),
        ChangeNotifierProvider(
          create: (_) => SavedItemsProvider(FirestoreSavedItemsService()),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
      ],
      child: child,
    );
  }
}
