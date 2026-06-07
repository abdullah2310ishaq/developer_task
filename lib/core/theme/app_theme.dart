import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    
    final baseTextStyle = TextStyle(color: AppColors.darkPrimary);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brightOrange),
      
      iconTheme: IconThemeData(color: AppColors.darkPrimary, size: 24.sp),
      
      textTheme: TextTheme(
        bodyMedium: baseTextStyle.copyWith(fontSize: 14.sp),
        bodyLarge: baseTextStyle.copyWith(fontSize: 16.sp),
        titleLarge: baseTextStyle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
        titleMedium: baseTextStyle.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
        toolbarHeight: 56.h,
        titleTextStyle: baseTextStyle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
        iconTheme: IconThemeData(color: AppColors.darkPrimary, size: 24.sp),
      ),
      
      dialogTheme: DialogThemeData(
        titleTextStyle: baseTextStyle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12.sp)),
      ),
    );
  }
}