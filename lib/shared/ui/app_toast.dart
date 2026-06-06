import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _currentOverlay;

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isSuccess: false);
  }

  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
    // Purane toast ko safety se hatao taake overlap na ho
    _currentOverlay?.remove();
    _currentOverlay = null;

    final baseColor = isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444); // Premium Emerald Green & Ruby Red
    final overlayState = Overlay.of(context);

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: 24.w,
        right: 24.w,
        bottom: bottomInset + 52.h,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic, // Smooth premium slide-up transition
            builder: (context, value, child) {
              return Transform.translate(
                // Value 0 se 1 jayegi, toh toast (20 * 1) yani 20px upar slide karega smoothly
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.black, // Dark sleek premium design
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Minimal indicator bar left side par icon ki jagah
                  Container(
                    width: 4.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_currentOverlay!);

    // Safe reference check taake memory leak ya galat toast remove na ho
    final localOverlay = _currentOverlay;
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (localOverlay == _currentOverlay) {
        _currentOverlay?.remove();
        _currentOverlay = null;
      }
    });
  }
}
