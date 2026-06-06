import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/theme/colors.dart';

class OrderStatusHero extends StatelessWidget {
  const OrderStatusHero({super.key, required this.status});

  final OrderTrackingStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: style.color.withValues(alpha: 0.28), width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 24.sp, color: style.color),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.title,
                  style: TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  style.subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _HeroStyle _styleFor(OrderTrackingStatus status) {
    return switch (status) {
      OrderPending() => const _HeroStyle(
        icon: Icons.receipt_long_rounded,
        color: AppColors.brightOrange,
        title: 'Order placed',
        subtitle: 'Waiting for kitchen to accept your order',
      ),
      OrderPreparing() => const _HeroStyle(
        icon: Icons.restaurant_rounded,
        color: AppColors.darkSecondary,
        title: 'Preparing your food',
        subtitle: 'Kitchen is working on your order',
      ),
      OrderOutForDelivery() => const _HeroStyle(
        icon: Icons.delivery_dining_rounded,
        color: AppColors.cleanGreen,
        title: 'On the way',
        subtitle: 'Your order is heading to you',
      ),
      OrderDelivered() => const _HeroStyle(
        icon: Icons.check_circle_rounded,
        color: AppColors.cleanGreen,
        title: 'Delivered',
        subtitle: 'Enjoy your meal!',
      ),
    };
  }
}

class _HeroStyle {
  const _HeroStyle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}
