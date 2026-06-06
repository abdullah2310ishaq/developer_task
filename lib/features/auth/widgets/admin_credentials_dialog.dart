import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/shared/ui/app_toast.dart';

class AdminCredentialsDialog extends StatelessWidget {
  const AdminCredentialsDialog({super.key});

  static const demoEmail = 'admin@app.com';
  static const demoPassword = '12345678';

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const AdminCredentialsDialog(),
    );
  }

  Future<void> _copy(BuildContext context, String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    AppToast.success(context, '$label copied');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin credentials',
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Demo Credentials',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13.sp,
                height: 1.35,
              ),
            ),
            SizedBox(height: 16.h),
            _CredentialRow(
              label: 'Email',
              value: demoEmail,
              onCopy: () => _copy(context, demoEmail, 'Email'),
            ),
            SizedBox(height: 12.h),
            _CredentialRow(
              label: 'Password',
              value: demoPassword,
              onCopy: () => _copy(context, demoPassword, 'Password'),
            ),
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Got it',
                  style: TextStyle(
                    color: AppColors.brightOrange,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_rounded,
              size: 20.sp,
              color: AppColors.brightOrange,
            ),
            tooltip: 'Copy $label',
          ),
        ],
      ),
    );
  }
}
