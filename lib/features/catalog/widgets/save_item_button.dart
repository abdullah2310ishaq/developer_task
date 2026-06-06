import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:developer_task/core/theme/colors.dart';
import 'package:developer_task/features/catalog/providers/saved_items_provider.dart';
import 'package:developer_task/shared/ui/app_toast.dart';

class SaveItemButton extends StatelessWidget {
  const SaveItemButton({
    super.key,
    required this.productId,
    this.iconSize,
    this.padding,
  });

  final String productId;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  Future<void> _toggle(BuildContext context) async {
    final saved = context.read<SavedItemsProvider>();
    final wasSaved = saved.isSaved(productId);
    final ok = await saved.toggle(productId);
    if (!context.mounted || !ok) {
      if (context.mounted && saved.errorMessage != null) {
        AppToast.error(context, saved.errorMessage!);
      }
      return;
    }
    AppToast.success(
      context,
      wasSaved ? 'Removed from saved' : 'Saved for later',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = context.select<SavedItemsProvider, bool>(
      (p) => p.isSaved(productId),
    );
    final size = iconSize ?? 22.sp;

    return IconButton(
      onPressed: () => _toggle(context),
      padding: padding ?? EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: size,
        color: isSaved ? AppColors.brightOrange : AppColors.textMuted,
      ),
    );
  }
}
