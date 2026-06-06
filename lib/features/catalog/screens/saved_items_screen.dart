import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/catalog/providers/catalog_provider.dart';
import 'package:developer_task/features/catalog/providers/saved_items_provider.dart';
import 'package:developer_task/features/catalog/widgets/product_grid_tile.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedItemsProvider>();
    final catalog = context.watch<CatalogProvider>();
    final products = saved.savedProducts(catalog.products);

    return _buildBody(saved, catalog, products);
  }

  Widget _buildBody(
    SavedItemsProvider saved,
    CatalogProvider catalog,
    List<Product> products,
  ) {
    if (saved.isLoading || (saved.savedIds.isNotEmpty && catalog.isLoading)) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: AppColors.brightOrange,
        ),
      );
    }

    if (saved.savedIds.isEmpty) {
      return _emptyState(
        title: 'No saved items yet',
        message: 'Tap the bookmark on any dish to order later',
      );
    }

    if (products.isEmpty) {
      return _emptyState(
        title: 'Saved items unavailable',
        message: 'These dishes may have been removed from the menu',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductGridTile(
          product: product,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: product,
          ),
        );
      },
    );
  }

  Widget _emptyState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 48.sp, color: AppColors.textMuted),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
