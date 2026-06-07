import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class DispatchRiderDialog {
  DispatchRiderDialog._();

  static Future<({String name, String phone})?> show(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog<({String name, String phone})>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        title: Text(
          'Dispatch rider',
          style: TextStyle(
            color: AppColors.darkPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Customer will see rider name and contact on their track screen.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp, height: 1.35),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Rider name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Rider contact',
                hintText: '03XXXXXXXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
              if (name.isEmpty || phone.length < 10) return;
              Navigator.pop(ctx, (name: name, phone: phone));
            },
            child: Text(
              'Dispatch',
              style: TextStyle(color: AppColors.cleanGreen, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
