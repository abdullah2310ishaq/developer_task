import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/admin/providers/admin_orders_provider.dart';
import 'package:developer_task/features/admin/widgets/admin_order_card.dart';
import 'package:developer_task/features/admin/widgets/admin_order_stats_row.dart';
import 'package:developer_task/features/admin/widgets/dispatch_rider_dialog.dart';
import 'package:developer_task/features/orders/widgets/order_history_tile.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/error_toast_listener.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _showHistory = false;

  Future<void> _handleAdvance(
    BuildContext context,
    AdminOrdersProvider provider,
    AppOrder order,
  ) async {
    provider.clearError();
    final live = provider.orderById(order.id) ?? order;

    if (live.status is OrderPending) {
      final ok = await provider.acceptOrder(live.id);
      if (!context.mounted) return;
      if (ok) {
        AppToast.success(context, 'Order accepted');
      } else {
        AppToast.error(context, provider.errorMessage ?? 'Status update failed');
      }
      return;
    }

    if (live.status is OrderPreparing) {
      final rider = await DispatchRiderDialog.show(context);
      if (!context.mounted || rider == null) return;

      final ok = await provider.dispatchOrder(
        live.id,
        riderName: rider.name,
        riderPhone: rider.phone,
      );
      if (!context.mounted) return;
      if (ok) {
        AppToast.success(context, 'Rider dispatched — customer notified');
      } else {
        AppToast.error(context, provider.errorMessage ?? 'Dispatch failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminOrdersProvider>();

    return ErrorToastListener(
      errorMessage: provider.errorMessage,
      child: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AdminOrdersProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty && provider.historyOrders.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: AppColors.brightOrange,
        ),
      );
    }

    if (provider.errorMessage != null &&
        provider.orders.isEmpty &&
        provider.historyOrders.isEmpty) {
      return Center(
        child: Text(
          provider.errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    final list = _showHistory ? provider.historyOrders : provider.orders;

    return Column(
      children: [
        if (!_showHistory)
          AdminOrderStatsRow(
            pending: provider.pendingCount,
            preparing: provider.preparingCount,
            dispatched: provider.dispatchedCount,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
          child: Row(
            children: [
              _TabChip(
                label: 'Active (${provider.orders.length})',
                selected: !_showHistory,
                onTap: () => setState(() => _showHistory = false),
              ),
              SizedBox(width: 8.w),
              _TabChip(
                label: 'History (${provider.historyOrders.length})',
                selected: _showHistory,
                onTap: () => setState(() => _showHistory = true),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    _showHistory
                        ? 'No completed orders yet.'
                        : 'No active orders right now.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final order = list[index];
                    if (_showHistory) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: OrderHistoryTile(
                          order: order,
                          showCustomer: true,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.adminOrderDetail,
                            arguments: order,
                          ),
                        ),
                      );
                    }

                    return AdminOrderCard(
                      order: order,
                      actionLabel: provider.actionLabel(order.status),
                      canAdvance: provider.canAdvance(order.status),
                      isUpdating: provider.isUpdating(order.id),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminOrderDetail,
                        arguments: order,
                      ),
                      onAdvance: () => _handleAdvance(context, provider, order),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.brightOrange.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: selected ? AppColors.brightOrange : AppColors.lightBorder,
              width: selected ? 1.5.w : 1.w,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.brightOrange : AppColors.textMuted,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
