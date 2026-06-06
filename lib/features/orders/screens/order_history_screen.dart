import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/features/orders/widgets/order_history_tile.dart';
import 'package:developer_task/shared/ui/error_toast_listener.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return ErrorToastListener(
      errorMessage: orders.errorMessage,
      child: _buildBody(orders),
    );
  }

  Widget _buildBody(OrderProvider orders) {
    if (orders.isLoading && orders.userOrders.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: AppColors.brightOrange,
        ),
      );
    }

    if (orders.errorMessage != null && orders.userOrders.isEmpty) {
      return Center(
        child: Text(
          orders.errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    if (orders.userOrders.isEmpty) {
      return Center(
        child: Text(
          'No orders yet',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.userOrders.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final order = orders.userOrders[index];
        return OrderHistoryTile(
          order: order,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.orderTrack,
            arguments: order.id,
          ),
        );
      },
    );
  }
}
