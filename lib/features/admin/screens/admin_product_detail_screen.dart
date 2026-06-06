import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';
import 'package:developer_task/shared/ui/food_image_preview_dialog.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class AdminProductDetailScreen extends StatelessWidget {
  const AdminProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final inStock = product.isInStock;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Item details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: AppColors.lightBorder),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          children: [
          GestureDetector(
            onTap: () => FoodImagePreviewDialog.show(
              context,
              imageUrl: product.imageUrl,
              title: product.name,
            ),
            child: CachedFoodImage(
              imageUrl: product.imageUrl,
              width: double.infinity,
              height: 220.h,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            product.name,
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppCurrency.format(product.price),
            style: TextStyle(
              color: AppColors.brightOrange,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            product.stockLabel,
            style: TextStyle(
              color: inStock ? AppColors.cleanGreen : AppColors.errorRed,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Category: ${product.category}',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Description',
            style: TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            product.description.isEmpty ? 'No description added.' : product.description,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp, height: 1.4),
          ),
          SizedBox(height: 28.h),
          PrimaryButton(
            label: 'Edit item',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.adminProductForm,
              arguments: product,
            ),
          ),
        ],
        ),
      ),
    );
  }
}
