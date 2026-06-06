import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/admin/providers/admin_orders_provider.dart';
import 'package:developer_task/features/admin/widgets/dispatch_rider_dialog.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  const AdminOrderDetailScreen({super.key, required this.order});

  final AppOrder order;

  Future<void> _handleAction(BuildContext context, AdminOrdersProvider provider) async {
    if (order.status is OrderPending) {
      final ok = await provider.acceptOrder(order);
      if (!context.mounted) return;
      if (ok) {
        AppToast.success(context, 'Order accepted');
        Navigator.pop(context);
      } else {
        AppToast.error(context, provider.errorMessage ?? 'Could not accept order');
      }
      return;
    }

    if (order.status is OrderPreparing) {
      final rider = await DispatchRiderDialog.show(context);
      if (!context.mounted || rider == null) return;

      final ok = await provider.dispatchOrder(
        order,
        riderName: rider.name,
        riderPhone: rider.phone,
      );
      if (!context.mounted) return;
      if (ok) {
        AppToast.success(context, 'Rider dispatched');
        Navigator.pop(context);
      } else {
        AppToast.error(context, provider.errorMessage ?? 'Dispatch failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminOrdersProvider>();
    final live = provider.orderById(order.id) ?? order;
    final money = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    final time = live.createdAt != null
        ? DateFormat('dd MMM · hh:mm a').format(live.createdAt!)
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${live.id.substring(0, 6).toUpperCase()}'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _InfoBlock(
              title: 'Status',
              child: Text(
                live.status.label,
                style: TextStyle(
                  color: AppColors.darkPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (time.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _InfoBlock(
                title: 'Placed at',
                child: Text(time, style: TextStyle(fontSize: 14.sp, color: AppColors.darkPrimary)),
              ),
            ],
            SizedBox(height: 12.h),
            _InfoBlock(
              title: 'Customer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(live.customerName ?? 'Customer', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Text(live.phone ?? '', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
                  SizedBox(height: 4.h),
                  Text(live.address ?? '', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, height: 1.35)),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _InfoBlock(
              title: 'Items (${live.itemCount})',
              child: Column(
                children: live.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.name} × ${item.quantity}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        Text(
                          money.format(item.price * item.quantity),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
            _InfoBlock(
              title: 'Payment',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${live.paymentMethod.toUpperCase()} · ${live.paymentStatus}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Total: ${AppCurrency.format(live.total)}',
                    style: TextStyle(
                      color: AppColors.brightOrange,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (live.riderName != null && live.riderName!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _InfoBlock(
                title: 'Rider',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(live.riderName!, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Text(live.riderPhone ?? '', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
            if (live.status is OrderPending || live.status is OrderPreparing) ...[
              SizedBox(height: 24.h),
              PrimaryButton(
                label: live.status is OrderPending ? 'Accept order' : 'Dispatch rider',
                isLoading: provider.isUpdating(live.id),
                backgroundColor: AppColors.cleanGreen,
                onPressed: () => _handleAction(context, provider),
              ),
            ] else if (live.status is OrderOutForDelivery) ...[
              SizedBox(height: 16.h),
              Text(
                'Waiting for customer to confirm delivery',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}
