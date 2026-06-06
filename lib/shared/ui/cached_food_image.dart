import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:developer_task/core/theme/colors.dart';

class CachedFoodImage extends StatelessWidget {
  const CachedFoodImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  static int _memCacheWidth(double layoutWidth) {
    if (layoutWidth.isFinite && layoutWidth > 0) {
      return layoutWidth.round().clamp(1, 4096);
    }
    return 800;
  }

  double _resolveLayoutWidth(BoxConstraints constraints, BuildContext context) {
    final explicit = width;
    if (explicit != null && explicit.isFinite && explicit > 0) return explicit;

    final fromParent = constraints.maxWidth;
    if (fromParent.isFinite && fromParent > 0) return fromParent;

    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth.isFinite && screenWidth > 0) return screenWidth;

    return 390;
  }

  Widget _image(double layoutWidth) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: layoutWidth,
      height: height,
      fit: fit,
      memCacheWidth: _memCacheWidth(layoutWidth),
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      placeholder: (_, __) => Container(
        width: layoutWidth,
        height: height,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textMuted,
          size: 24.sp,
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: layoutWidth,
        height: height,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textMuted,
          size: 24.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(6.r);

    return ClipRRect(
      borderRadius: radius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layoutWidth = _resolveLayoutWidth(constraints, context);
          return _image(layoutWidth);
        },
      ),
    );
  }
}
