import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/features/admin/providers/admin_orders_provider.dart';
import 'package:developer_task/features/admin/providers/admin_products_provider.dart';
import 'package:developer_task/features/admin/widgets/admin_home_shell.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/notification_permission_dialog.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _tabIndex = 0;

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

    final admin = auth.currentUser;
    if (admin == null) return;

    await auth.waitForAuthReady();
    if (!mounted) return;

    context.read<NotificationProvider>().startListening(admin.uid, isAdmin: true);
    context.read<AdminProductsProvider>().startListening();
    context.read<AdminOrdersProvider>().startListening(admin.uid);

    await NotificationPermissionDialog.showIfNeeded(context);
  }

  void _stopAdminListeners() {
    context.read<AdminProductsProvider>().stopListening();
    context.read<AdminOrdersProvider>().stopListening();
    context.read<NotificationProvider>().stopListening();
  }

  void _exitDashboard() {
    _stopAdminListeners();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (_) => false,
    );
  }

  Future<void> _logout() async {
    _stopAdminListeners();

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
    final orderCount = context.select<AdminOrdersProvider, int>(
      (p) => p.orders.length,
    );
    final unread = context.select<NotificationProvider, int>((p) => p.unreadCount);

    return AdminHomeShell(
      tabIndex: _tabIndex,
      orderCount: orderCount,
      unreadNotifications: unread,
      onTabChanged: (i) => setState(() => _tabIndex = i),
      onExitDashboard: _exitDashboard,
      onLogout: _logout,
      onAddProduct: () =>
          Navigator.pushNamed(context, AppRoutes.adminProductForm),
      onOpenNotifications: () => Navigator.pushNamed(context, AppRoutes.notifications),
    );
  }
}
