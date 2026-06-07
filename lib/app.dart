import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/app_providers.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/app_theme.dart';
import 'package:developer_task/features/admin/screens/admin_home_screen.dart';
import 'package:developer_task/core/models/app_order.dart';
import 'package:developer_task/features/admin/screens/admin_order_detail_screen.dart';
import 'package:developer_task/features/admin/screens/admin_product_detail_screen.dart';
import 'package:developer_task/features/admin/screens/admin_product_form_screen.dart';
import 'package:developer_task/features/auth/screens/admin_login_screen.dart';
import 'package:developer_task/features/auth/screens/profile_setup_screen.dart';
import 'package:developer_task/features/auth/screens/role_selection_screen.dart';
import 'package:developer_task/features/auth/screens/splash_screen.dart';
import 'package:developer_task/features/auth/screens/user_login_screen.dart';
import 'package:developer_task/features/catalog/screens/product_detail_screen.dart';
import 'package:developer_task/features/checkout/screens/checkout_screen.dart';
import 'package:developer_task/features/notifications/screens/notifications_screen.dart';
import 'package:developer_task/features/orders/screens/order_track_screen.dart';
import 'package:developer_task/features/user/screens/edit_profile_screen.dart';
import 'package:developer_task/features/user/screens/user_home_screen.dart';

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) {
        return AppProviders(
          child: MaterialApp(
            title: 'Delivery App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            routes: _routes,
            onGenerateRoute: _onGenerateRoute,
          ),
        );
      },
    );
  }
}

final Map<String, WidgetBuilder> _routes = {
  AppRoutes.splash: (_) => const SplashScreen(),
  AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
  AppRoutes.userLogin: (_) => const UserLoginScreen(),
  AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
  AppRoutes.profileSetup: (_) => const ProfileSetupScreen(),
  AppRoutes.userHome: (_) => const UserHomeScreen(),
  AppRoutes.editProfile: (_) => const EditProfileScreen(),
  AppRoutes.adminHome: (_) => const AdminHomeScreen(),
  AppRoutes.checkout: (_) => const CheckoutScreen(),
  AppRoutes.notifications: (_) => const NotificationsScreen(),
};

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.adminProductForm:
      final product = settings.arguments as Product?;
      return MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(product: product),
      );
    case AppRoutes.adminProductDetail:
      final product = settings.arguments as Product;
      return MaterialPageRoute(
        builder: (_) => AdminProductDetailScreen(product: product),
      );
    case AppRoutes.productDetail:
      final product = settings.arguments as Product;
      return MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      );
    case AppRoutes.orderTrack:
      final orderId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => OrderTrackScreen(orderId: orderId),
      );
    case AppRoutes.adminOrderDetail:
      final order = settings.arguments as AppOrder;
      return MaterialPageRoute(
        builder: (_) => AdminOrderDetailScreen(order: order),
      );
  }
  return null;
}
