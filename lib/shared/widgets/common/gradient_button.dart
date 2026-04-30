import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_gradients.dart';
import '../../constants/app_text_styles.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final double radius;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.height = 52,
    this.radius = 16,
    this.gradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null || widget.isLoading) return;

    setState(() => _pressed = false);

    // 🔥 HAPTIC (more reliable)
    HapticFeedback.lightImpact();

    widget.onTap!();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onTap == null || widget.isLoading;

    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _pressed ? 0.96 : 1.0,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : (widget.gradient ?? AppGradients.primary),
            color: isDisabled ? AppColors.primary4 : null,
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.label,
                  style: AppTextStyles.button.copyWith(
                    color: isDisabled ? AppColors.textHint : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
