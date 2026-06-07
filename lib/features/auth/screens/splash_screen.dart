import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/utils/auth_navigation.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/notification_permission_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 900)),
      auth.restoreSession(),
    ]);
    if (!mounted) return;

    if (auth.errorMessage != null) {
      AppToast.error(context, auth.errorMessage!);
    }

    await NotificationPermissionDialog.showAtAppStart(context);
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      userRouteAfterAuth(auth.currentUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decent & Minimalist Text
            Text(
              'Food Delivery App',
              style: TextStyle(
                color: AppColors.darkPrimary,
                fontSize: 22.sp,
                fontWeight:
                    FontWeight.w500, // Medium weight for modern/clean look
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24.h),
            // Minimal Loading Indicator
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.0.w, // Slightly thinner stroke for elegance
                color: AppColors.brightOrange,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
