import 'package:flutter/material.dart';
import '../../../utils/constants/app_gradients.dart';
import '../../../utils/constants/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: Stack(
          children: [
            // ── blob top-right ──────────────────────────
            Positioned(
              top: -100, right: -90,
              child: Container(
                width: 340, height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            // ── blob bottom-left ────────────────────────
            Positioned(
              bottom: 60, left: -80,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // ── splash-blob (bottom-right mid) ──────────
            Positioned(
              bottom: 180, right: 20,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // ── floating decorative characters ──────────
            const Positioned(
              top: 55, left: 28,
              child: Opacity(opacity: 0.30,
                child: Text('💜', style: TextStyle(fontSize: 32))),
            ),
            const Positioned(
              top: 110, right: 38,
              child: Opacity(opacity: 0.20,
                child: Text('✦',
                  style: TextStyle(fontSize: 28, color: Colors.white))),
            ),
            const Positioned(
              bottom: 170, left: 38,
              child: Opacity(opacity: 0.20,
                child: Text('⬡',
                  style: TextStyle(fontSize: 24, color: Colors.white))),
            ),
            const Positioned(
              bottom: 210, right: 28,
              child: Opacity(opacity: 0.15,
                child: Text('◈',
                  style: TextStyle(fontSize: 40, color: Colors.white))),
            ),

            // ── main centred content ─────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo  — Syne 800, white, 64px, ls -2
                  Text(
                    'zuno',
                    style: AppTextStyles.logo().copyWith(
                      fontSize: 64,
                      letterSpacing: -2,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0x33000000),
                          blurRadius: 24,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  Text(
                    'Find your spark ✦',
                    style: AppTextStyles.body().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.40)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '✦ 50K+ matches made',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Spinner
                  SizedBox(
                    width: 36, height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}