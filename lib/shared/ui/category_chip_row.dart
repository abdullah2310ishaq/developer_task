import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == selected;
          return FilterChip(
            label: Text(category),
            selected: isActive,
            onSelected: (_) => onSelected(category),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.brightOrange.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: isActive ? AppColors.brightOrange : AppColors.darkSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isActive ? AppColors.brightOrange : AppColors.lightBorder,
              width: 1.w,
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
