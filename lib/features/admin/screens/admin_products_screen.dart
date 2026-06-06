import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/admin/providers/admin_products_provider.dart';
import 'package:developer_task/features/admin/widgets/admin_product_card.dart';
import 'package:developer_task/features/admin/widgets/admin_product_delete_dialog.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/category_chip_row.dart';
import 'package:developer_task/shared/ui/error_toast_listener.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    String productId,
    String productName,
  ) async {
    final ok = await AdminProductDeleteDialog.show(
      context,
      productName: productName,
    );
    if (!ok || !context.mounted) return;

    final provider = context.read<AdminProductsProvider>();
    final success = await provider.removeProduct(productId);
    if (!context.mounted) return;

    if (success) {
      AppToast.success(context, 'Product removed');
    } else {
      AppToast.error(context, provider.errorMessage ?? 'Could not delete product');
    }
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.pushNamed(
      context,
      AppRoutes.adminProductDetail,
      arguments: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProductsProvider>();

    return ErrorToastListener(
      errorMessage: provider.errorMessage,
      child: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AdminProductsProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: AppColors.brightOrange,
        ),
      );
    }

    if (provider.errorMessage != null && provider.products.isEmpty) {
      return Center(
        child: Text(
          provider.errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Text(
          'No menu items yet.\nTap Add item to create your first dish.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    final filtered = provider.filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8.h),
        CategoryChipRow(
          categories: provider.categories,
          selected: provider.selectedCategory,
          onSelected: context.read<AdminProductsProvider>().selectCategory,
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    provider.selectedCategory == 'All'
                        ? 'No menu items yet.\nTap Add item to create your first dish.'
                        : 'No items in ${provider.selectedCategory}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 88.h),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return AdminProductCard(
                      product: product,
                      onTap: () => _openDetail(context, product),
                      onEdit: () => Navigator.pushNamed(
                        context,
                        AppRoutes.adminProductForm,
                        arguments: product,
                      ),
                      onDelete: () => _confirmDelete(context, product.id, product.name),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
