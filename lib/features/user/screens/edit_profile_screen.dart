import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/auth/providers/auth_provider.dart';
import 'package:developer_task/features/auth/widgets/auth_text_field.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        phone.length != 11) {
      AppToast.error(context, 'Fill name, address and 11-digit phone');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.saveProfile(
      displayName: _nameController.text,
      phone: phone,
      address: _addressController.text,
    );

    if (!mounted) return;
    if (success) {
      AppToast.success(context, 'Profile updated');
      Navigator.pop(context);
      return;
    }
    AppToast.error(context, auth.errorMessage ?? 'Save failed');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          children: [
            Text(
              'Update your delivery details anytime.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
            ),
            SizedBox(height: 20.h),
            AuthTextField(controller: _nameController, label: 'Full name', hint: 'Your name'),
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'From Google',
              readOnly: true,
            ),
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _phoneController,
              label: 'Phone',
              hint: '03XXXXXXXXX',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            AuthTextField(
              controller: _addressController,
              label: 'Delivery address',
              hint: 'House, street, city',
            ),
            SizedBox(height: 28.h),
            PrimaryButton(
              label: 'Save changes',
              isLoading: isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
