import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/features/orders/widgets/order_status_hero.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.waitForAuthReady();
    if (!mounted) return;

    final userId = auth.currentUser?.uid;
    if (userId == null) return;

    context.read<NotificationProvider>().ensureListening(userId, isAdmin: false);
    context.read<OrderProvider>().trackOrder(widget.orderId, userId);
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
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                children: [
                  OrderStatusHero(status: order.status),
                  SizedBox(height: 14.h),
                  _OrderSummaryCard(
                    orderId: order.id,
                    itemsSummary: order.itemsSummary,
                    itemCount: order.itemCount,
                    total: order.total,
                  ),
                  SizedBox(height: 16.h),
                  OrderTimeline(current: order.status),
                  if (order.status is OrderOutForDelivery) ...[
                    SizedBox(height: 16.h),
                    if (order.riderName != null && order.riderName!.isNotEmpty) ...[
                      RiderInfoCard(
                        riderName: order.riderName!,
                        riderPhone: order.riderPhone ?? '',
                      ),
                      SizedBox(height: 14.h),
                      PrimaryButton(
                        label: 'I received my order',
                        isLoading: isLoading,
                        backgroundColor: AppColors.cleanGreen,
                        onPressed: _confirmReceived,
                      ),
                    ] else
                      _InfoNote(
                        text: 'Rider details will appear here shortly.',
                        icon: Icons.delivery_dining_outlined,
                      ),
                  ],
                  if (order.status is OrderDelivered) ...[
                    SizedBox(height: 16.h),
                    _InfoNote(
                      text: 'Thanks for ordering with FreshBite!',
                      icon: Icons.celebration_outlined,
                      color: AppColors.cleanGreen,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.orderId,
    required this.itemsSummary,
    required this.itemCount,
    required this.total,
  });

  final String orderId;
  final String itemsSummary;
  final int itemCount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${orderId.substring(0, 6).toUpperCase()}',
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            itemsSummary,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp, height: 1.35),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '$itemCount items',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
              const Spacer(),
              Text(
                AppCurrency.format(total),
                style: TextStyle(
                  color: AppColors.brightOrange,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({
    required this.text,
    required this.icon,
    this.color = AppColors.textMuted,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
