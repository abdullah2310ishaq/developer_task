import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/admin/screens/admin_orders_screen.dart';
import 'package:developer_task/features/admin/screens/admin_products_screen.dart';
import 'package:developer_task/shared/ui/app_session_dialog.dart';
import 'package:developer_task/features/admin/widgets/admin_shell_nav_bar.dart';
import 'package:developer_task/shared/ui/keep_alive_tab.dart';
import 'package:developer_task/shared/ui/notification_bell_button.dart';

class AdminHomeShell extends StatelessWidget {
  const AdminHomeShell({
    super.key,
    required this.tabIndex,
    required this.orderCount,
    required this.onTabChanged,
    required this.onExitDashboard,
    required this.onLogout,
    required this.onAddProduct,
    required this.unreadNotifications,
    required this.onOpenNotifications,
  });

  final int tabIndex;
  final int orderCount;
  final int unreadNotifications;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onExitDashboard;
  final VoidCallback onLogout;
  final VoidCallback onAddProduct;
  final VoidCallback onOpenNotifications;

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    if (action == 'exit') {
      final choice = await AppSessionDialog.showExitConfirm(
        context,
        title: 'Exit dashboard?',
        message: 'You will return to role selection. Your admin session stays signed in.',
      );
      if (choice == SessionLeaveAction.exit) onExitDashboard();
      return;
    }
    if (action == 'logout') {
      final confirmed = await AppSessionDialog.showLogoutConfirm(
        context,
        title: 'Logout?',
        message: 'You will be signed out completely. Login again to access the admin dashboard.',
      );
      if (confirmed) onLogout();
    }
  }

  Future<void> _handleBackPress(BuildContext context) async {
    final choice = await AppSessionDialog.showExitConfirm(
      context,
      title: 'Exit dashboard?',
      message: 'You will return to role selection. Your admin session stays signed in.',
    );
    if (choice == SessionLeaveAction.exit) onExitDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final tab = AdminShellTab.fromIndex(tabIndex);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            tab.label,
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.darkPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(height: 1.h, color: AppColors.lightBorder),
          ),
          automaticallyImplyLeading: false,
          actions: [
            NotificationBellButton(
              unreadCount: unreadNotifications,
              onPressed: onOpenNotifications,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 24.sp, color: AppColors.darkPrimary),
              color: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
                side: BorderSide(color: AppColors.lightBorder, width: 1.w),
              ),
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'exit',
                  child: Text('Exit dashboard', style: TextStyle(fontSize: 14.sp)),
                ),
                PopupMenuDivider(height: 1.h),
                PopupMenuItem(
                  value: 'logout',
                  child: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.errorRed, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
          ],
        ),
        floatingActionButton: tab == AdminShellTab.menu
            ? FloatingActionButton.extended(
                backgroundColor: AppColors.brightOrange,
                foregroundColor: AppColors.background,
                onPressed: onAddProduct,
                icon: Icon(Icons.add_rounded, size: 22.sp),
                label: Text(
                  'Add item',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              )
            : null,
        body: IndexedStack(
          index: tabIndex,
          children: const [
            KeepAliveTab(child: AdminProductsScreen()),
            KeepAliveTab(child: AdminOrdersScreen()),
          ],
        ),
        bottomNavigationBar: AdminShellNavBar(
          selectedIndex: tabIndex,
          orderCount: orderCount,
          onSelected: onTabChanged,
        ),
      ),
    );
  }
}
