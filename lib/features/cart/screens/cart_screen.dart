import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/models/cart_item.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/cart/widgets/cart_line_tile.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hasItems = context.select<CartProvider, bool>((p) => p.hasItems);
    final items = context.select<CartProvider, List<CartItem>>((p) => p.items);
    final subtotal = context.select<CartProvider, double>((p) => p.subtotal);

    if (!hasItems) {
      return Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            itemCount: items.length,
            itemBuilder: (_, index) => CartLineTile(item: items[index]),
          ),
        ),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.lightBorder, width: 1.w)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal (${AppCurrency.code})',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textMuted),
                  ),
                  Text(
                    AppCurrency.format(subtotal),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              PrimaryButton(
                label: 'Proceed to checkout',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
