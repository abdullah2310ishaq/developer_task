import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/shared/ui/primary_button.dart';
import 'package:intl/intl.dart';

class AdminOrderCard extends StatelessWidget {
  const AdminOrderCard({
    super.key,
    required this.order,
    required this.actionLabel,
    required this.isUpdating,
    required this.canAdvance,
    required this.onTap,
    required this.onAdvance,
  });

  final AppOrder order;
  final String actionLabel;
  final bool isUpdating;
  final bool canAdvance;
  final VoidCallback onTap;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    final time = order.createdAt != null
        ? DateFormat('hh:mm a').format(order.createdAt!)
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
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
                    'Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      color: AppColors.darkPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              order.customerName ?? 'Customer',
              style: TextStyle(color: AppColors.darkPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              order.itemsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.darkPrimary, fontSize: 13.sp, height: 1.35),
            ),
            SizedBox(height: 4.h),
            Text(
              '${order.itemCount} items · ${money.format(order.total)}',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(time, style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp)),
            ],
            if (order.riderName != null && order.riderName!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                'Rider: ${order.riderName} · ${order.riderPhone ?? ''}',
                style: TextStyle(color: AppColors.cleanGreen, fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
            SizedBox(height: 8.h),
            Text(
              'Tap for full details',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
            ),
            if (canAdvance) ...[
              SizedBox(height: 12.h),
              PrimaryButton(
                label: actionLabel,
                isLoading: isUpdating,
                backgroundColor: AppColors.cleanGreen,
                onPressed: onAdvance,
              ),
            ] else if (order.status is OrderOutForDelivery) ...[
              SizedBox(height: 10.h),
              Text(
                'Waiting for customer confirmation',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
