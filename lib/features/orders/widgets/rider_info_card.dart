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
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cleanGreen.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your order is on the way',
            style: TextStyle(
              color: AppColors.cleanGreen,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            riderName,
            style: TextStyle(color: AppColors.darkPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  riderPhone,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                ),
              ),
              TextButton.icon(
                onPressed: _callRider,
                icon: Icon(Icons.phone_rounded, size: 18.sp, color: AppColors.cleanGreen),
                label: Text(
                  'Call rider',
                  style: TextStyle(color: AppColors.cleanGreen, fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
