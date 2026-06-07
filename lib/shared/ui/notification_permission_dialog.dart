import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/shared/data/services/notification_service.dart';

class NotificationPermissionDialog {
  static Future<void> showIfNeeded(BuildContext context) async {
    final service = NotificationService.instance;
    if (await service.areNotificationsEnabled()) return;
    if (!context.mounted) return;

    final allow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Order alerts'),
        content: const Text(
          'Turn on notifications to get pings when orders are placed, accepted, dispatched, or delivered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not now', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Allow', style: TextStyle(color: AppColors.brightOrange, fontSize: 14.sp)),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (allow == true) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final granted = await service.requestPermission();
      if (!context.mounted) return;
      if (!granted) {
        await _showSettingsPrompt(context);
      }
      return;
    }

    if (!context.mounted) return;
    await _showSettingsPrompt(context);
  }

  static Future<void> _showSettingsPrompt(BuildContext context) async {
    if (!context.mounted) return;
    if (await NotificationService.instance.areNotificationsEnabled()) return;
    if (!context.mounted) return;

    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notifications are off'),
        content: const Text(
          'Enable notifications in app settings to get order pings on your phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Later', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Open settings', style: TextStyle(color: AppColors.brightOrange, fontSize: 14.sp)),
          ),
        ],
      ),
    );

    if (open == true) {
      await openAppSettings();
    }
  }
}
