import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zuno_application/utils/constants/app_colors.dart';
import 'package:zuno_application/utils/constants/app_gradients.dart';
import 'package:zuno_application/utils/constants/app_text_styles.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final dynamic profile;
  final String heroTag;

  const ProfileDetailsScreen({
    super.key,
    required this.profile,
    required this.heroTag,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  double imageOffset = 0;
  bool showHeart = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        imageOffset = _scrollController.offset * 0.4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,

      /// 🔥 STICKY BUTTON BAR
      bottomNavigationBar: _bottomBar(),

      body: Stack(
        children: [
          /// SCROLL CONTENT
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              _buildContent(isDark),
            ],
          ),

          /// ❤️ DOUBLE TAP ANIMATION
          if (showHeart)
            Center(
              child: TweenAnimationBuilder(
                tween: Tween(begin: 0.6, end: 1.4),
                duration: const Duration(milliseconds: 400),
                builder: (_, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: 1 - (scale - 0.6),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 120,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ================= PARALLAX APP BAR =================

Widget _buildAppBar() {
  return SliverAppBar(
    expandedHeight: 340,
    pinned: true,
    stretch: true,
    backgroundColor: AppColors.black,

    leading: _iconBtn(Icons.arrow_back_ios_new_rounded, Get.back),
    actions: [
      _iconBtn(Icons.more_horiz, () {}),
      const SizedBox(width: 10),
    ],

    flexibleSpace: FlexibleSpaceBar(
      background: GestureDetector(
        onDoubleTap: () {
          setState(() => showHeart = true);
          Future.delayed(const Duration(milliseconds: 500),
              () => setState(() => showHeart = false));
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// PARALLAX IMAGE WITH FALLBACK
            Transform.translate(
              offset: Offset(0, imageOffset),
              child: Hero(
                tag: widget.heroTag,
                child: widget.profile.profileImageUrl.isNotEmpty
                    ? Image.network(
                        widget.profile.profileImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return _placeholderImage();
                        },
                      )
                    : _placeholderImage(),
              ),
            ),

            /// BLUR OVERLAY
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
            ),

            /// BOTTOM GRADIENT
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 140,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.swipeOverlayDark
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Placeholder widget for missing or failed image
Widget _placeholderImage() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.profilePlaceholderStart,
          AppColors.profilePlaceholderEnd,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: const Center(
      child: Icon(
        Icons.person,
        size: 90,
        color: AppColors.white,
      ),
    ),
  );
}
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ================= CONTENT =================

  Widget _buildContent(bool isDark) {
    final p = widget.profile;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAME & AGE
            Row(
              children: [
                Text(p.userName, style: AppTextStyles.headingLarge(isDark: isDark)),
                const SizedBox(width: 6),
                Text(p.age, style: AppTextStyles.headingMedium(isDark: isDark)),
              ],
            ),

            const SizedBox(height: 6),

            /// LOCATION
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint),
                const SizedBox(width: 4),
                Text(p.location, style: AppTextStyles.bodySmall(isDark: isDark)),
              ],
            ),

            const SizedBox(height: 18),

            /// ABOUT (always expanded)
            _buildSection(
              title: "About 👋",
              isDark: isDark,
              child: Text(
                p.bio,
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            ),

            const SizedBox(height: 16),

            /// INTERESTS (always expanded)
            _buildSection(
              title: "Interests",
              isDark: isDark,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: p.interests.map<Widget>((e) => _chip(e)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingMedium(isDark: isDark)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall().copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= BOTTOM BAR =================

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              child: const Text("Skip"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text("Like ❤️"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}