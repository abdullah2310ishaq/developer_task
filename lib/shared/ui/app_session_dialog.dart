import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

enum SessionLeaveAction { cancel, exit }

class AppSessionDialog {
  AppSessionDialog._();

  static Future<SessionLeaveAction> showExitConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String exitLabel = 'Exit',
  }) {
    return showDialog<SessionLeaveAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, SessionLeaveAction.cancel),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, SessionLeaveAction.exit),
            child: Text(exitLabel, style: TextStyle(color: AppColors.darkPrimary, fontSize: 14.sp)),
          ),
        ],
      ),
    ).then((value) => value ?? SessionLeaveAction.cancel);
  }

  static Future<bool> showLogoutConfirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.errorRed, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
