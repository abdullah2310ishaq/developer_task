import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/models/product.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/admin/providers/admin_products_provider.dart';
import 'package:developer_task/features/admin/widgets/product_image_picker.dart';
import 'package:developer_task/features/auth/widgets/auth_text_field.dart';
import 'package:developer_task/shared/ui/app_toast.dart';
import 'package:developer_task/shared/ui/primary_button.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _picker = ImagePicker();
  File? _pickedImage;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(0);
      _categoryController.text = product.category;
      _stockController.text = product.stock.toString();
    } else {
      _stockController.text = '10';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? -1;
    final provider = context.read<AdminProductsProvider>();
    final success = await provider.saveProduct(
      existing: widget.product,
      name: _nameController.text,
      description: _descController.text,
      price: price,
      stock: stock,
      category: _categoryController.text,
      imageFile: _pickedImage,
      existingImageUrl: widget.product?.imageUrl,
    );

    if (!mounted) return;
    if (success) {
      AppToast.success(context, _isEdit ? 'Product updated' : 'Product added');
      Navigator.pop(context);
      return;
    }
    AppToast.error(context, provider.errorMessage ?? 'Save failed');
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AdminProductsProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit product' : 'Add product'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          children: [
          ProductImagePicker(
            localFile: _pickedImage,
            remoteUrl: widget.product?.imageUrl,
            onPick: _pickImage,
          ),
          SizedBox(height: 20.h),
          AuthTextField(controller: _nameController, label: 'Name', hint: 'Chicken Burger'),
          SizedBox(height: 16.h),
          AuthTextField(
            controller: _priceController,
            label: 'Price (PKR)',
            hint: '850',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          AuthTextField(
            controller: _stockController,
            label: 'Stock quantity',
            hint: '50',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          AuthTextField(
            controller: _categoryController,
            label: 'Category',
            hint: 'Burgers, Pizza, Drinks',
          ),
          SizedBox(height: 16.h),
          AuthTextField(
            controller: _descController,
            label: 'Description',
            hint: 'Juicy patty, fresh veggies',
          ),
          SizedBox(height: 28.h),
          PrimaryButton(
            label: _isEdit ? 'Save changes' : 'Add to menu',
            isLoading: isSaving,
            onPressed: _save,
          ),
        ],
        ),
      ),
    );
  }
}
