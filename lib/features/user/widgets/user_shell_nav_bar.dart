import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

enum UserShellTab {
  catalog('Menu'),
  saved('Saved'),
  cart('Cart'),
  orders('Orders');

  const UserShellTab(this.label);

  final String label;

  static UserShellTab fromIndex(int index) => values[index];
}

class UserShellNavBar extends StatelessWidget {
  const UserShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.cartCount,
    required this.savedCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int cartCount;
  final int savedCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.lightBorder, width: 1.w)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                label: UserShellTab.catalog.label,
                icon: Icons.restaurant_menu_outlined,
                selectedIcon: Icons.restaurant_menu,
                selected: selectedIndex == UserShellTab.catalog.index,
                onTap: () => onSelected(UserShellTab.catalog.index),
              ),
            ),
            _divider(),
            Expanded(
              child: _NavItem(
                label: UserShellTab.saved.label,
                icon: Icons.bookmark_border_rounded,
                selectedIcon: Icons.bookmark_rounded,
                selected: selectedIndex == UserShellTab.saved.index,
                badgeCount: savedCount,
                onTap: () => onSelected(UserShellTab.saved.index),
              ),
            ),
            _divider(),
            Expanded(
              child: _NavItem(
                label: UserShellTab.cart.label,
                icon: Icons.shopping_bag_outlined,
                selectedIcon: Icons.shopping_bag,
                selected: selectedIndex == UserShellTab.cart.index,
                badgeCount: cartCount,
                onTap: () => onSelected(UserShellTab.cart.index),
              ),
            ),
            _divider(),
            Expanded(
              child: _NavItem(
                label: UserShellTab.orders.label,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                selected: selectedIndex == UserShellTab.orders.index,
                onTap: () => onSelected(UserShellTab.orders.index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1.w, height: 40.h, color: AppColors.lightBorder);
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brightOrange : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Badge(
            isLabelVisible: badgeCount > 0,
            label: Text('$badgeCount'),
            child: Icon(
              selected ? selectedIcon : icon,
              size: 24.sp,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
