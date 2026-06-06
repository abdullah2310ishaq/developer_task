import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/catalog/widgets/save_item_button.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';
import 'package:intl/intl.dart';

class ProductGridTile extends StatelessWidget {
  const ProductGridTile({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    final inStock = product.isInStock;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Opacity(
        opacity: inStock ? 1 : 0.55,
        child: Container(
          height: 84.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightBorder, width: 1.w),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Stack(
                children: [
                  CachedFoodImage(
                    imageUrl: product.imageUrl,
                    width: 84.w,
                    height: 84.h,
                    borderRadius: BorderRadius.zero,
                  ),
                  if (!inStock)
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Out',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.darkPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            price.format(product.price),
                            style: TextStyle(
                              color: AppColors.brightOrange,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (inStock) ...[
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                product.stockLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SaveItemButton(productId: product.id, iconSize: 20.sp),
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
