import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class AdminOrderStatsRow extends StatelessWidget {
  const AdminOrderStatsRow({
    super.key,
    required this.pending,
    required this.preparing,
    required this.dispatched,
  });

  final int pending;
  final int preparing;
  final int dispatched;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          Expanded(child: _StatChip(label: 'New', count: pending, color: AppColors.brightOrange)),
          SizedBox(width: 8.w),
          Expanded(child: _StatChip(label: 'Kitchen', count: preparing, color: AppColors.darkSecondary)),
          SizedBox(width: 8.w),
          Expanded(child: _StatChip(label: 'On way', count: dispatched, color: AppColors.cleanGreen)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.w),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(color: color, fontSize: 18.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
