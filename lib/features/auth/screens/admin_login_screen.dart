import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/constants/app_routes.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/widgets/admin_credentials_dialog.dart';
import 'package:developer_task/features/auth/widgets/auth_text_field.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillDemo() {
    _usernameController.text = AdminCredentialsDialog.demoEmail;
    _passwordController.text = AdminCredentialsDialog.demoPassword;
    AppToast.success(context, 'Credentials filled');
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      AppToast.error(context, 'Enter username and password');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signInAsAdmin(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      AppToast.success(context, 'Admin logged in');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.adminHome,
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
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Admin login',
                      style: TextStyle(
                        color: AppColors.darkPrimary,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => AdminCredentialsDialog.show(context),
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 24.sp,
                      color: AppColors.textMuted,
                    ),
                    tooltip: 'Demo credentials',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Username & password for login',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
              ),
              SizedBox(height: 32.h),
              AuthTextField(
                controller: _usernameController,
                label: 'Username',
                hint: AdminCredentialsDialog.demoEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _autofillDemo,
                  icon: Icon(Icons.auto_fix_high_rounded, size: 20.sp),
                  label: Text(
                    'Autofill ',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brightOrange,
                    side: BorderSide(color: AppColors.brightOrange, width: 1.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              PrimaryButton(
                label: 'Sign in',
                isLoading: isLoading,
                backgroundColor: AppColors.cleanGreen,
                onPressed: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
