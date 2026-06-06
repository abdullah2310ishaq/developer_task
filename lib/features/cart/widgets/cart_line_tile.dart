import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/models/cart_item.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/catalog/providers/catalog_provider.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';

class CartLineTile extends StatelessWidget {
  const CartLineTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final maxStock = context.select<CatalogProvider, int>(
      (p) => p.productById(item.productId)?.stock ?? 0,
    );
    final canIncrease = item.quantity < maxStock;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder, width: 1.w),
      ),
      child: Row(
        children: [
          CachedFoodImage(imageUrl: item.imageUrl, width: 64.w, height: 64.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.darkPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppCurrency.format(item.lineTotal),
                  style: TextStyle(color: AppColors.brightOrange, fontSize: 13.sp),
                ),
                if (maxStock > 0)
                  Text(
                    '$maxStock left',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => cart.updateQuantity(item.productId, item.quantity - 1, maxStock: maxStock),
            icon: Icon(Icons.remove_circle_outline, size: 22.sp),
          ),
          Text('${item.quantity}', style: TextStyle(fontSize: 14.sp)),
          IconButton(
            onPressed: canIncrease
                ? () {
                    final error = cart.updateQuantity(
                      item.productId,
                      item.quantity + 1,
                      maxStock: maxStock,
                    );
                    if (error != null) AppToast.error(context, error);
                  }
                : null,
            icon: Icon(
              Icons.add_circle_outline,
              size: 22.sp,
              color: canIncrease ? null : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
