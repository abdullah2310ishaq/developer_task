import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/notifications/providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
    if (isAdmin) return;

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
