import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/utils/auth_navigation.dart';
import 'package:developer_task/features/auth/widgets/google_sign_in_button.dart';
import 'package:developer_task/shared/ui/app_toast.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool _isResuming = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.warmUpGoogleSignIn();
    final resumed = await auth.tryResumeCustomerSession();
    if (!mounted) return;

    if (resumed) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        userRouteAfterAuth(auth.currentUser),
        (_) => false,
      );
      return;
    }

    setState(() => _isResuming = false);
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (!context.mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        userRouteAfterAuth(auth.currentUser),
        (_) => false,
      );
      return;
    }

    if (auth.errorMessage != null) {
      AppToast.error(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading || _isResuming;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Text(
                          'Customer login',
                          style: TextStyle(
                            color: AppColors.darkPrimary,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Sign in with your Google account to order food',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
                        ),
                        SizedBox(height: 48.h),
                        GoogleSignInButton(
                          isLoading: isLoading,
                          onPressed: () => _handleGoogleSignIn(context),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 24.h, bottom: 16.h),
                      child: Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Back to role selection',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
