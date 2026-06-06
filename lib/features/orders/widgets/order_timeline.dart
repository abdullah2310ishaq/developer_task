import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/enums/order_tracking_status.dart';
import 'package:developer_task/core/theme/colors.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.current});

  final OrderTrackingStatus current;

  @override
  Widget build(BuildContext context) {
    final steps = OrderTrackingStatus.timeline;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order progress',
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isDone = current.stepIndex > step.stepIndex;
            final isCurrent = current.stepIndex == step.stepIndex;
            final isLast = index == steps.length - 1;

            return _TimelineStep(
              step: step,
              isDone: isDone,
              isCurrent: isCurrent,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  final OrderTrackingStatus step;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  IconData get _icon => switch (step) {
        OrderPending() => Icons.shopping_bag_outlined,
        OrderPreparing() => Icons.soup_kitchen_outlined,
        OrderOutForDelivery() => Icons.moped_outlined,
        OrderDelivered() => Icons.home_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final dotColor = isDone || isCurrent ? AppColors.cleanGreen : AppColors.lightBorder;
    final iconColor = isDone || isCurrent ? AppColors.background : AppColors.textMuted;
    final titleColor = isCurrent ? AppColors.darkPrimary : (isDone ? AppColors.darkPrimary : AppColors.textMuted);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: isDone || isCurrent ? AppColors.cleanGreen : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? AppColors.brightOrange : dotColor,
                    width: isCurrent ? 2.w : 1.w,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.brightOrange.withValues(alpha: 0.25),
                            blurRadius: 8.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : _icon,
                  size: 16.sp,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isDone ? AppColors.cleanGreen : AppColors.lightBorder,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h, top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14.sp,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Current step',
                      style: TextStyle(
                        color: AppColors.brightOrange,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
