import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/enums/payment_types.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/core/models/cart_item.dart';
import 'package:developer_task/core/utils/app_currency.dart';
import 'package:developer_task/features/auth/models/app_user.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/cart/providers/cart_provider.dart';
import 'package:developer_task/features/orders/providers/order_provider.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  Future<bool?> _confirmStripePayment(BuildContext context, String orderTotal) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stripe payment'),
        content: Text(
          'Your app order total is $orderTotal (PKR, from cart products).\n\n'
          'Complete payment on the Stripe test page, then return and tap I paid.\n'
          'Note: Stripe test link may show a fixed dashboard price — your saved order uses cart prices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('I paid'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final user = auth.currentUser;
    if (user == null) {
      AppToast.error(context, 'Please login again');
      return;
    }

    var stripePaymentConfirmed = false;

    if (orders.usesStripePaymentLink) {
      final opened = await orders.openStripePaymentLink();
      if (!context.mounted) return;
      if (!opened) {
        AppToast.error(context, 'Could not open Stripe checkout');
        return;
      }

      final confirmed = await _confirmStripePayment(
        context,
        AppCurrency.format(cart.subtotal),
      );
      if (!context.mounted) return;
      if (confirmed != true) return;
      stripePaymentConfirmed = true;
    }

    final orderId = await orders.placeOrder(
      user: user,
      cart: cart,
      stripePaymentConfirmed: stripePaymentConfirmed,
    );
    if (!context.mounted) return;

    if (orderId != null) {
      AppToast.success(context, 'Order placed');
      orders.trackOrder(orderId, user.uid);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderTrack,
        (route) => route.settings.name == AppRoutes.userHome,
        arguments: orderId,
      );
      return;
    }

    AppToast.error(context, orders.errorMessage ?? 'Checkout failed');
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.select<CartProvider, List<CartItem>>(
      (p) => p.items,
    );
    final subtotal = context.select<CartProvider, double>((p) => p.subtotal);
    final selectedMethod = context.select<OrderProvider, PaymentMethod>(
      (p) => p.selectedMethod,
    );
    final isPlacingOrder = context.select<OrderProvider, bool>(
      (p) => p.isPlacingOrder,
    );
    final usesPaymentLink = context.select<OrderProvider, bool>(
      (p) => p.usesStripePaymentLink,
    );
    final usesStripeInApp = context.select<OrderProvider, bool>(
      (p) => p.usesStripeInAppPayment,
    );
    final user = context.select<AuthProvider, AppUser?>((p) => p.currentUser);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Text(
              'Deliver to',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 8.h),
            Text(
              user?.displayName ?? '',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              user?.phone ?? '',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              user?.address ?? '',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              'Order summary (PKR)',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 10.h),
            ...cartItems.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} × ${item.quantity}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Text(
                      AppCurrency.format(item.lineTotal),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Payment',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 10.h),
            _PayTile(
              label: const PaymentCashOnDelivery().label,
              selected: selectedMethod is PaymentCashOnDelivery,
              onTap: () => context.read<OrderProvider>().selectPaymentMethod(
                const PaymentCashOnDelivery(),
              ),
            ),
            SizedBox(height: 10.h),
            _PayTile(
              label: usesStripeInApp
                  ? 'Online Payment'
                  : usesPaymentLink
                  ? 'Card (Stripe test link)'
                  : const PaymentStripe().label,
              selected: selectedMethod is PaymentStripe,
              onTap: () => context.read<OrderProvider>().selectPaymentMethod(
                const PaymentStripe(),
              ),
            ),
            if (usesStripeInApp) ...[
              SizedBox(height: 8.h),
            ] else if (usesPaymentLink) ...[
              SizedBox(height: 8.h),
              Text(
                'Order saved at cart total in PKR. Stripe browser page may show a fixed test amount.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${AppCurrency.code})',
                  style: TextStyle(fontSize: 16.sp),
                ),
                Text(
                  AppCurrency.format(subtotal),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            PrimaryButton(
              label: selectedMethod is PaymentStripe && usesStripeInApp
                  ? 'Pay ${AppCurrency.format(subtotal)}'
                  : selectedMethod is PaymentStripe && usesPaymentLink
                  ? 'Pay with Stripe'
                  : 'Place order',
              isLoading: isPlacingOrder,
              onPressed: () => _placeOrder(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayTile extends StatelessWidget {
  const _PayTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.brightOrange : AppColors.lightBorder,
            width: selected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.brightOrange : AppColors.textMuted,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
