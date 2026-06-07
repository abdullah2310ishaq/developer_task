import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/admin/providers/admin_orders_provider.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/notification_permission_dialog.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshPermissionStatus());
  }

  Future<void> _refreshPermissionStatus() async {
    if (!mounted) return;
    final granted = await context.read<NotificationProvider>().areNotificationsEnabled();
    if (!mounted) return;
    setState(() => _permissionGranted = granted);
  }

  Future<void> _requestPermission() async {
    await NotificationPermissionDialog.showIfNeeded(context);
    if (!mounted) return;
    await _refreshPermissionStatus();
    if (!mounted || _permissionGranted) return;
    AppToast.error(context, 'Allow notifications to get order pings');
  }

  Future<void> _openNotification(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final provider = context.read<NotificationProvider>();
    final id = item['id'] as String?;
    final isRead = item['read'] == true;

    if (id != null && !isRead) {
      await provider.markAsRead(id);
    }

    final orderId = item['orderId'] as String?;
    if (orderId == null || !context.mounted) return;

    final isAdmin = context.read<AuthProvider>().currentUser?.role.isAdmin ?? false;
    if (isAdmin) {
      final order = context.read<AdminOrdersProvider>().orderById(orderId);
      if (order == null) {
        AppToast.error(context, 'Order not found');
        return;
      }
      Navigator.pushNamed(context, AppRoutes.adminOrderDetail, arguments: order);
      return;
    }

    Navigator.pushNamed(context, AppRoutes.orderTrack, arguments: orderId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                'Mark all read',
                style: TextStyle(color: AppColors.brightOrange, fontSize: 13.sp),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!_permissionGranted)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                child: Material(
                  color: AppColors.brightOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  child: InkWell(
                    onTap: _requestPermission,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 20.sp, color: AppColors.brightOrange),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Notifications are off. Tap to allow order alerts.',
                              style: TextStyle(color: AppColors.darkPrimary, fontSize: 13.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                      ),
                    )
                  : ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _NotificationTile(
                    item: item,
                    onTap: () => _openNotification(context, item),
                    onToggleRead: () {
                      final id = item['id'] as String?;
                      if (id == null) return;
                      if (item['read'] == true) {
                        provider.markAsUnread(id);
                      } else {
                        provider.markAsRead(id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onToggleRead,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    final isRead = item['read'] == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isRead ? AppColors.lightBorder : AppColors.brightOrange.withValues(alpha: 0.45),
              width: isRead ? 1.w : 1.5.w,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRead)
                Padding(
                  padding: EdgeInsets.only(top: 6.h, right: 10.w),
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String? ?? 'Update',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                        color: AppColors.darkPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['body'] as String? ?? '',
                      style: TextStyle(
                        color: isRead ? AppColors.textMuted : AppColors.darkSecondary,
                        fontSize: 13.sp,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      isRead ? 'Read' : 'Unread',
                      style: TextStyle(
                        color: isRead ? AppColors.textMuted : AppColors.brightOrange,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleRead,
                icon: Icon(
                  isRead ? Icons.mark_email_unread_outlined : Icons.done_all_rounded,
                  size: 20.sp,
                  color: AppColors.textMuted,
                ),
                tooltip: isRead ? 'Mark unread' : 'Mark read',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
