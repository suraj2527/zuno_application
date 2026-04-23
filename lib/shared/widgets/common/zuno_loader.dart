import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ZunoLoader extends StatefulWidget {
  final bool isVisible;

  const ZunoLoader({super.key, required this.isVisible});

  @override
  State<ZunoLoader> createState() => _ZunoLoaderState();
}

class _ZunoLoaderState extends State<ZunoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _bounce(double t, double offset) {
    return sin((t * 2 * pi) + offset) * 6;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          /// 🌫️ BLUR + DARK OVERLAY (blocks all taps)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // blocks clicks
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.35)),
              ),
            ),
          ),

          /// 🔵 LOADER CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final t = _controller.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _dot(t, 0, AppColors.primary),
                        const SizedBox(width: 8),
                        _dot(t, 2, AppColors.accent),
                        const SizedBox(width: 8),
                        _dot(t, 4, AppColors.primary2),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                /// ✨ FADE IN TEXT
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeIn,
                  ),
                  child: const Text(
                    "Just a moment, magic is loading...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double t, double offset, Color color) {
    return Transform.translate(
      offset: Offset(0, _bounce(t, offset)),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
        ),
      ),
    );
  }
}
