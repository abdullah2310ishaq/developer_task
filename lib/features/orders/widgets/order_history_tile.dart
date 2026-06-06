import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/core/theme/colors.dart';

class OrderHistoryTile extends StatelessWidget {
  const OrderHistoryTile({
    super.key,
    required this.order,
    required this.onTap,
    this.showCustomer = false,
  });

  final AppOrder order;
  final VoidCallback onTap;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    final date = order.createdAt != null
        ? DateFormat('dd MMM · hh:mm a').format(order.createdAt!)
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.lightBorder, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            if (showCustomer) ...[
              SizedBox(height: 6.h),
              Text(
                order.customerName ?? 'Customer',
                style: TextStyle(
                  color: AppColors.darkPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (order.phone != null && order.phone!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  order.phone!,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ],
            ],
            SizedBox(height: 8.h),
            Text(
              order.itemsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 13.sp,
                height: 1.35,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (date.isNotEmpty)
                  Expanded(
                    child: Text(
                      date,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                    ),
                  ),
                Text(
                  money.format(order.total),
                  style: TextStyle(
                    color: AppColors.brightOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderTrackingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderPending() => AppColors.brightOrange,
      OrderPreparing() => AppColors.darkSecondary,
      OrderOutForDelivery() => AppColors.cleanGreen,
      OrderDelivered() => AppColors.textMuted,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
