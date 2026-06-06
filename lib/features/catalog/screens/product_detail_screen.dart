import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/catalog/providers/catalog_provider.dart';
import 'package:developer_task/features/catalog/widgets/save_item_button.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/cached_food_image.dart';
import 'package:developer_task/shared/ui/food_image_preview_dialog.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  void _addToCart(Product product) {
    final error = context.read<CartProvider>().addProduct(
      product,
      quantity: _qty,
    );
    if (!mounted) return;
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    AppToast.success(context, 'Added to cart');
  }

  @override
  Widget build(BuildContext context) {
    final product = context.select<CatalogProvider, Product>(
      (p) => p.productById(widget.product.id) ?? widget.product,
    );
    final price = AppCurrency.pkr;
    final inStock = product.isInStock;
    final maxQty = product.stock;

    if (_qty > maxQty && maxQty > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _qty = maxQty);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
        actions: [
          SaveItemButton(productId: product.id),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
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
                SizedBox(height: 6.h),
                Text(
                  price.format(product.price),
                  style: TextStyle(
                    color: AppColors.brightOrange,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  product.stockLabel,
                  style: TextStyle(
                    color: inStock ? AppColors.cleanGreen : AppColors.errorRed,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  product.description,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
                if (!inStock) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'This item is currently unavailable',
                    style: TextStyle(
                      color: AppColors.errorRed,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.lightBorder, width: 1.w),
              ),
            ),
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.only(bottom: 6.h),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (inStock)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Text(
                              'Quantity',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_qty > 1) setState(() => _qty--);
                              },
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              '$_qty',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () {
                                if (_qty < maxQty) setState(() => _qty++);
                              },
                            ),
                          ],
                        ),
                      ),
                    PrimaryButton(
                      label: inStock ? 'Add to cart' : 'Out of stock',
                      onPressed: inStock ? () => _addToCart(product) : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.lightBorder, width: 1.w),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.darkPrimary),
      ),
    );
  }
}
