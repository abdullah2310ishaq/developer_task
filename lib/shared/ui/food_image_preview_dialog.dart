import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';

class FoodImagePreviewDialog extends StatelessWidget {
  const FoodImagePreviewDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  final String imageUrl;
  final String? title;

  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => FoodImagePreviewDialog(imageUrl: imageUrl, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.lightBorder, width: 1.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                    child: Text(
                      title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12.r),
                    top: title != null && title!.isNotEmpty
                        ? Radius.zero
                        : Radius.circular(12.r),
                  ),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: SizedBox(
                      width: double.infinity,
                      height: 0.55.sh,
                      child: CachedFoodImage(
                        imageUrl: imageUrl,
                        height: 0.55.sh,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10.h,
            right: -6.w,
            child: Material(
              color: AppColors.background,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22.sp,
                    color: AppColors.darkPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
