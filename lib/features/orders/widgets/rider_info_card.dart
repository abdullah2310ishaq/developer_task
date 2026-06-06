import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderInfoCard extends StatelessWidget {
  const RiderInfoCard({
    super.key,
    required this.riderName,
    required this.riderPhone,
  });

  final String riderName;
  final String riderPhone;

  Future<void> _callRider() async {
    final uri = Uri.parse('tel:$riderPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cleanGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.cleanGreen.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.cleanGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 24.sp, color: AppColors.cleanGreen),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your rider',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
                SizedBox(height: 2.h),
                Text(
                  riderName,
                  style: TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  riderPhone,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _callRider,
            icon: Icon(Icons.phone_rounded, size: 18.sp, color: AppColors.cleanGreen),
            label: Text(
              'Call',
              style: TextStyle(
                color: AppColors.cleanGreen,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
