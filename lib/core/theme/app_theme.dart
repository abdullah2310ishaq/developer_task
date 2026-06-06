import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData build() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brightOrange),
      useMaterial3: true,
      iconTheme: IconThemeData(color: AppColors.darkPrimary, size: 24.sp),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: AppColors.darkPrimary, fontSize: 14.sp),
        bodyLarge: TextStyle(color: AppColors.darkPrimary, fontSize: 16.sp),
        titleLarge: TextStyle(
          color: AppColors.darkPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
        toolbarHeight: 56.h,
        titleTextStyle: TextStyle(
          color: AppColors.darkPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.darkPrimary, size: 24.sp),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          color: AppColors.darkPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14.sp,
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12.sp)),
      ),
    );
  }
}
