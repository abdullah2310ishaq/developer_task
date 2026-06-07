import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

enum AdminShellTab {
  menu('Menu'),
  orders('Orders');

  const AdminShellTab(this.label);

  final String label;

  static AdminShellTab fromIndex(int index) => values[index];
}

class AdminShellNavBar extends StatelessWidget {
  const AdminShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.orderCount,
    required this.onSelected,
  });

  final int selectedIndex;
  final int orderCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        constraints: BoxConstraints(minHeight: 56.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.lightBorder, width: 1.w),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                label: AdminShellTab.menu.label,
                icon: Icons.restaurant_menu_outlined,
                selectedIcon: Icons.restaurant_menu,
                selected: selectedIndex == AdminShellTab.menu.index,
                onTap: () => onSelected(AdminShellTab.menu.index),
              ),
            ),
            Container(width: 1.w, height: 40.h, color: AppColors.lightBorder),
            Expanded(
              child: _NavItem(
                label: AdminShellTab.orders.label,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                selected: selectedIndex == AdminShellTab.orders.index,
                badgeCount: orderCount,
                onTap: () => onSelected(AdminShellTab.orders.index),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        mainAxisSize: MainAxisSize.min,
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
