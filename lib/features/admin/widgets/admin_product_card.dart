import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';

class AdminProductCard extends StatelessWidget {
  const AdminProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  void _onMenuSelected(String action) {
    switch (action) {
      case 'details':
        onTap();
      case 'edit':
        onEdit();
      case 'delete':
        onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                CachedFoodImage(
                  imageUrl: product.imageUrl,
                  width: 72.w,
                  height: 72.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.darkPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppCurrency.format(product.price),
                        style: TextStyle(
                          color: AppColors.brightOrange,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.stockLabel,
                        style: TextStyle(
                          color: product.isInStock ? AppColors.cleanGreen : AppColors.errorRed,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 22.sp, color: AppColors.darkSecondary),
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    side: BorderSide(color: AppColors.lightBorder, width: 1.w),
                  ),
                  onSelected: _onMenuSelected,
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'details',
                      child: Text('View details', style: TextStyle(fontSize: 14.sp)),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit', style: TextStyle(fontSize: 14.sp)),
                    ),
                    PopupMenuDivider(height: 1.h),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.errorRed, fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
