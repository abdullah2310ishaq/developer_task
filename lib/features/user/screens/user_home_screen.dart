import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/catalog/providers/catalog_provider.dart';
import 'package:developer_task/features/catalog/providers/saved_items_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/features/user/widgets/user_home_shell.dart';
import 'package:developer_task/shared/ui/app_toast.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _tabIndex = 0;

  void _syncCartWithCatalog() {
    if (!mounted) return;
    final products = context.read<CatalogProvider>().products;
    context.read<CartProvider>().syncWithProducts(products);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final valid = auth.currentUser != null || await auth.validateSession();
    if (!mounted) return;
    if (!valid) {
      AppToast.error(
        context,
        auth.errorMessage ?? 'Session expired. Please login again.',
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.roleSelection,
        (_) => false,
      );
      return;
    }

    final user = auth.currentUser;
    if (user == null) return;

    await context.read<NotificationProvider>().initLocal();
    if (!mounted) return;

    final catalog = context.read<CatalogProvider>();
    catalog.addListener(_syncCartWithCatalog);
    catalog.startListening();
    context.read<OrderProvider>().startUserOrders(user.uid);
    context.read<NotificationProvider>().startListening(user.uid);
    context.read<SavedItemsProvider>().startListening(user.uid);
  }

  @override
  void dispose() {
    context.read<CatalogProvider>().removeListener(_syncCartWithCatalog);
    super.dispose();
  }

  void _stopUserListeners() {
    context.read<CatalogProvider>().removeListener(_syncCartWithCatalog);
    context.read<CatalogProvider>().stopListening();
    context.read<OrderProvider>().stopUserOrders();
    context.read<NotificationProvider>().stopListening();
    context.read<SavedItemsProvider>().stopListening();
  }

  void _exitApp() {
    _stopUserListeners();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );
  }

  Future<void> _logout() async {
    _stopUserListeners();
    context.read<CartProvider>().clear();

    final auth = context.read<AuthProvider>();
    auth.beginSignOut();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );

    await auth.executeSignOut();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.select<CartProvider, int>((p) => p.itemCount);
    final savedCount = context.select<SavedItemsProvider, int>((p) => p.count);
    final unread = context.select<NotificationProvider, int>((p) => p.unreadCount);

    return UserHomeShell(
      tabIndex: _tabIndex,
      cartCount: cartCount,
      savedCount: savedCount,
      unreadNotifications: unread,
      onTabChanged: (i) => setState(() => _tabIndex = i),
      onExitApp: _exitApp,
      onLogout: _logout,
      onOpenNotifications: () => Navigator.pushNamed(context, AppRoutes.notifications),
    );
  }
}
