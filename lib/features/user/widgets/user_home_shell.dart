import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/cart/screens/cart_screen.dart';
import 'package:developer_task/features/catalog/screens/catalog_screen.dart';
import 'package:developer_task/features/catalog/screens/saved_items_screen.dart';
import 'package:developer_task/features/orders/screens/order_history_screen.dart';
import 'package:developer_task/features/user/widgets/user_shell_nav_bar.dart';
import 'package:developer_task/shared/ui/app_session_dialog.dart';
import 'package:developer_task/shared/ui/keep_alive_tab.dart';
import 'package:developer_task/shared/ui/notification_bell_button.dart';

class UserHomeShell extends StatelessWidget {
  const UserHomeShell({
    super.key,
    required this.tabIndex,
    required this.cartCount,
    required this.savedCount,
    required this.unreadNotifications,
    required this.onTabChanged,
    required this.onExitApp,
    required this.onLogout,
    required this.onOpenNotifications,
  });

  final int tabIndex;
  final int cartCount;
  final int savedCount;
  final int unreadNotifications;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onExitApp;
  final VoidCallback onLogout;
  final VoidCallback onOpenNotifications;

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    if (action == 'exit') {
      final choice = await AppSessionDialog.showExitConfirm(
        context,
        title: 'Exit app?',
        message: 'You will return to role selection. Your account stays signed in.',
      );
      if (choice == SessionLeaveAction.exit) onExitApp();
      return;
    }
    if (action == 'logout') {
      final confirmed = await AppSessionDialog.showLogoutConfirm(
        context,
        title: 'Logout?',
        message: 'You will be signed out completely. Login again to order food.',
      );
      if (confirmed) onLogout();
    }
  }

  Future<void> _handleBackPress(BuildContext context) async {
    final choice = await AppSessionDialog.showExitConfirm(
      context,
      title: 'Exit app?',
      message: 'You will return to role selection. Your account stays signed in.',
    );
    if (choice == SessionLeaveAction.exit) onExitApp();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (UserShellTab.fromIndex(tabIndex)) {
      UserShellTab.catalog => 'FreshBite',
      UserShellTab.saved => 'Saved for later',
      UserShellTab.cart => 'Cart',
      UserShellTab.orders => 'Orders',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackPress(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            title,
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
                  child: Text('Exit app', style: TextStyle(fontSize: 14.sp)),
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
        body: IndexedStack(
          index: tabIndex,
          children: const [
            KeepAliveTab(child: CatalogScreen()),
            KeepAliveTab(child: SavedItemsScreen()),
            KeepAliveTab(child: CartScreen()),
            KeepAliveTab(child: OrderHistoryScreen()),
          ],
        ),
        bottomNavigationBar: UserShellNavBar(
          selectedIndex: tabIndex,
          cartCount: cartCount,
          savedCount: savedCount,
          onSelected: onTabChanged,
        ),
      ),
    );
  }
}
