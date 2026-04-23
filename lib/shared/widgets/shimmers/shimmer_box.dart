import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A single shimmer-animated box. Use inside [ShimmerWrapper].
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // overridden by gradient in ShimmerWrapper
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Wraps children with a sweeping shimmer gradient animation.
class ShimmerWrapper extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerWrapper({super.key, required this.child, this.isLoading = true});

  @override
  State<ShimmerWrapper> createState() => _ShimmerWrapperState();
}

class _ShimmerWrapperState extends State<ShimmerWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: isDark
                ? const [
                    AppColors.inputFillDark,
                    AppColors.inputBorderDark,
                    AppColors.inputFillDark,
                  ]
                : const [
                    AppColors.primary4,
                    AppColors.cardLight,
                    AppColors.primary4,
                  ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
