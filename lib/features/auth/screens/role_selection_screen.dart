import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/utils/auth_navigation.dart';
import 'package:developer_task/features/auth/widgets/role_option_card.dart';
import 'package:developer_task/shared/ui/logging_out_overlay.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().warmUpGoogleSignIn();
    });
  }

  Future<void> _openCustomer(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final resumed = await auth.tryResumeCustomerSession();
    if (!context.mounted) return;

    if (resumed) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        userRouteAfterAuth(auth.currentUser),
        (_) => false,
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.userLogin);
  }

  @override
  Widget build(BuildContext context) {
    final isSigningOut = context.watch<AuthProvider>().isSigningOut;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Choose your role',
                      style: TextStyle(color: Colors.black54, fontSize: 15.sp),
                    ),
                    SizedBox(height: 32.h),
                    RoleOptionCard(
                      title: 'Customer',
                      onTap: isSigningOut ? () {} : () => _openCustomer(context),
                    ),
                    SizedBox(height: 12.h),
                    RoleOptionCard(
                      title: 'Admin',
                      onTap: isSigningOut
                          ? () {}
                          : () => Navigator.pushNamed(context, AppRoutes.adminLogin),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSigningOut) const LoggingOutOverlay(),
        ],
      ),
    );
  }
}
