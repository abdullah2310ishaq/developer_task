import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/theme/colors.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.current});

  final OrderTrackingStatus current;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: OrderTrackingStatus.timeline.map((step) {
        final active = current.stepIndex >= step.stepIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.cleanGreen
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? AppColors.cleanGreen : AppColors.lightBorder,
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  active ? Icons.check : Icons.circle,
                  size: 16.sp,
                  color: active ? AppColors.background : AppColors.textMuted,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                step.label,
                style: TextStyle(
                  color: active ? AppColors.darkPrimary : AppColors.textMuted,
                  fontSize: 15.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
