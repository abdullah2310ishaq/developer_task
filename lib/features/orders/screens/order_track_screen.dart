import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/features/orders/widgets/order_timeline.dart';
import 'package:developer_task/features/orders/widgets/rider_info_card.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class OrderTrackScreen extends StatefulWidget {
  const OrderTrackScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.uid;
      if (userId != null) {
        context.read<NotificationProvider>().startListening(userId);
        context.read<OrderProvider>().trackOrder(widget.orderId, userId);
      }
    });
  }

  Future<void> _confirmReceived() async {
    final ok = await context.read<OrderProvider>().confirmReceived(widget.orderId);
    if (!mounted) return;
    if (ok) {
      AppToast.success(context, 'Thanks! Order completed');
    } else {
      AppToast.error(
        context,
        context.read<OrderProvider>().errorMessage ?? 'Could not confirm',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().trackedOrder;
    final isLoading = context.watch<OrderProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track order'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: order == null
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  color: AppColors.brightOrange,
                ),
              )
            : ListView(
                padding: EdgeInsets.all(20.w),
                children: [
                  Text(
                    '#${order.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      color: AppColors.darkPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    order.itemsSummary,
                    style: TextStyle(color: AppColors.darkPrimary, fontSize: 13.sp, height: 1.35),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.itemCount} items · ${AppCurrency.format(order.total)}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
                  ),
                  SizedBox(height: 20.h),
                  OrderTimeline(current: order.status),
                  if (order.status is OrderOutForDelivery &&
                      order.riderName != null &&
                      order.riderName!.isNotEmpty) ...[
                    RiderInfoCard(
                      riderName: order.riderName!,
                      riderPhone: order.riderPhone ?? '',
                    ),
                    SizedBox(height: 16.h),
                    PrimaryButton(
                      label: 'I received my order',
                      isLoading: isLoading,
                      backgroundColor: AppColors.cleanGreen,
                      onPressed: _confirmReceived,
                    ),
                  ] else if (order.status is OrderOutForDelivery) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Your order is on the way. Rider details will appear shortly.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
                    ),
                  ],
                  if (order.status is OrderDelivered) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Order delivered. Enjoy your meal!',
                      style: TextStyle(
                        color: AppColors.cleanGreen,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
