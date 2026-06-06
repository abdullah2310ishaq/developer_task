import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import 'package:developer_task/core/constants/app_routes.dart';

import 'package:developer_task/core/theme/colors.dart';

import 'package:developer_task/features/catalog/providers/catalog_provider.dart';

import 'package:developer_task/shared/ui/category_chip_row.dart';

import 'package:developer_task/features/catalog/widgets/product_grid_tile.dart';

import 'package:developer_task/shared/ui/error_toast_listener.dart';



class CatalogScreen extends StatelessWidget {

  const CatalogScreen({super.key});



  @override

  Widget build(BuildContext context) {

    final catalog = context.watch<CatalogProvider>();



    return ErrorToastListener(

      errorMessage: catalog.errorMessage,

      child: _buildBody(context, catalog),

    );

  }



  Widget _buildBody(BuildContext context, CatalogProvider catalog) {

    if (catalog.isLoading && catalog.products.isEmpty) {

      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: AppColors.brightOrange,
        ),
      );

    }



    if (catalog.errorMessage != null && catalog.products.isEmpty) {

      return Center(

        child: Text(

          catalog.errorMessage!,

          textAlign: TextAlign.center,

          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),

        ),

      );

    }



    if (catalog.filteredProducts.isEmpty) {

      return Center(

        child: Text(

          'No items yet.\nAdmin can add menu from dashboard.',

          textAlign: TextAlign.center,

          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),

        ),

      );

    }



    return Column(

      children: [

        SizedBox(height: 8.h),

        CategoryChipRow(

          categories: catalog.categories,

          selected: catalog.selectedCategory,

          onSelected: context.read<CatalogProvider>().selectCategory,

        ),

        SizedBox(height: 12.h),

        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            itemCount: catalog.filteredProducts.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final product = catalog.filteredProducts[index];
              return ProductGridTile(
                product: product,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.productDetail,
                  arguments: product,
                ),
              );
            },
          ),
        ),

      ],

    );

  }

}


