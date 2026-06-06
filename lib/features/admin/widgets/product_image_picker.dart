import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';

class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({
    super.key,
    required this.localFile,
    required this.remoteUrl,
    required this.onPick,
  });

  final File? localFile;
  final String? remoteUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightBorder, width: 1.w),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (localFile != null) {
      return Image.file(localFile!, fit: BoxFit.cover, width: double.infinity);
    }
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return CachedFoodImage(
        imageUrl: remoteUrl!,
        width: double.infinity,
        height: 180.h,
        borderRadius: BorderRadius.zero,
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 32.sp, color: AppColors.textMuted),
        SizedBox(height: 8.h),
        Text(
          'Tap to upload food photo',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
        ),
      ],
    );
  }
}
