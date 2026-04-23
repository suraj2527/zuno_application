import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearly/core/services/auth_service.dart';
import 'package:nearly/data/sources/remote/home_api.dart';
import 'package:nearly/shared/constants/app_colors.dart';
import 'package:nearly/shared/constants/app_gradients.dart';
import 'package:nearly/shared/constants/app_text_styles.dart';
import 'package:nearly/presentation/dashboard/dashboard_controller.dart' as nearly_dashboard;


enum ProfileOpenedFrom {
  home,
  likes,
  matches,
  chat,
}

class ProfileDetailsScreen extends StatefulWidget {
  final dynamic profile;
  final String heroTag;
  final ProfileOpenedFrom openedFrom;

  const ProfileDetailsScreen({
    super.key,
    required this.profile,
    required this.heroTag,
    required this.openedFrom,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final HomeApi _homeApi = HomeApi();
  final AuthService _authService = AuthService();

  double imageOffset = 0;
  bool showHeart = false;
  int currentGalleryIndex = 0;
  bool isLikeLoading = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        // imageOffset = _scrollController.offset * 0.4;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.profile;

    if (p == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Profile",
            style: AppTextStyles.headingMedium(isDark: isDark),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "This profile is not available right now.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(isDark: isDark),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.primary5,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [_buildAppBar(p), _buildContent(isDark, p)],
          ),

          if (widget.openedFrom != ProfileOpenedFrom.chat)
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: SafeArea(
                top: false,
                child: widget.openedFrom == ProfileOpenedFrom.matches
                    ? _buildChatButton()
                    : _buildLikeButton(),
              ),
            ),

          /// ❤️ double tap animation
          if (showHeart)
            Center(
              child: TweenAnimationBuilder(
                tween: Tween(begin: 0.6, end: 1.4),
                duration: const Duration(milliseconds: 400),
                builder: (_, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: (1.4 - scale).clamp(0.0, 1.0),
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

  Widget _buildLikeButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: (isLikeLoading || isLiked) ? null : _likeProfile,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isLikeLoading
                      ? const SizedBox(
                          key: ValueKey("like_loader"),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.favorite_rounded,
                          key: ValueKey("like_icon"),
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  isLiked
                      ? "Liked"
                      : (isLikeLoading ? "Liking..." : "Like Profile"),
                  style: AppTextStyles.bodyMedium(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _likeProfile() async {
    final targetUserId = (widget.profile?.id ?? "").toString().trim();
    if (targetUserId.isEmpty) {
      Get.snackbar("Error", "Invalid profile");
      return;
    }

    setState(() => isLikeLoading = true);
    try {
      final token = await _authService.currentUser?.getIdToken(true);
      if (token == null || token.isEmpty) throw "Token not found";

      await _homeApi.sendDiscoveryAction(
        token: token,
        targetUserId: targetUserId,
        action: "like",
      );

      Get.snackbar("Liked", "You liked this profile");
      if (mounted) setState(() => isLiked = true);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      if (mounted) setState(() => isLikeLoading = false);
    }
  }

  Widget _buildChatButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Get.back();
            try {
              Get.find<nearly_dashboard.DashboardController>().changeTab(1);
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  "Chat",
                  style: AppTextStyles.bodyMedium(isDark: false).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar(dynamic profile) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.black,
      leading: _iconBtn(Icons.arrow_back_ios_new_rounded, Get.back),
      actions: [
        _iconBtn(Icons.more_horiz_rounded, () {}),
        const SizedBox(width: 10),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onDoubleTap: () {
            setState(() => showHeart = true);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) setState(() => showHeart = false);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(0, imageOffset),
                child: Hero(
                  tag: widget.heroTag,
                  child: _buildImage(profile.profileImageUrl),
                ),
              ),

              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(color: Colors.transparent),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.swipeOverlayDark],
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

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ================= CONTENT =================

  Widget _buildContent(bool isDark, dynamic p) {
    final List<String> galleryImages = (p.imageUrls is List<String>)
        ? p.imageUrls
        : <String>[];
    final hasLocation = _hasText((p.location ?? '').toString());
    final hasGender = _hasText((p.gender ?? '').toString());
    final hasLookingFor = _hasText((p.lookingFor ?? '').toString());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAME / AGE / STATUS
            _buildProfileHeader(isDark, p),

            const SizedBox(height: 18),

            /// ABOUT
            _buildSection(
              title: "About 👋",
              isDark: isDark,
              child: Text(
                (p.bio ?? '').toString().trim().isNotEmpty
                    ? p.bio
                    : "No bio added yet",
                style: AppTextStyles.bodyMedium(
                  isDark: isDark,
                ).copyWith(height: 1.55),
              ),
            ),

            const SizedBox(height: 16),

            /// INFO
            if (hasLocation) ...[
              _buildInfoCard(
                isDark: isDark,
                title: "Location",
                value: p.location,
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 14),
            ],

            if (hasGender) ...[
              _buildInfoCard(
                isDark: isDark,
                title: "Gender",
                value: p.gender,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
            ],

            if (hasLookingFor) ...[
              _buildInfoCard(
                isDark: isDark,
                title: "Looking For",
                value: p.lookingFor,
                icon: Icons.favorite_border_rounded,
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 2),

            /// INTERESTS
            _buildSection(
              title: "Interests",
              isDark: isDark,
              child: (p.interests != null && p.interests.isNotEmpty)
                  ? Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: p.interests
                          .map<Widget>((e) => _chip(e, isDark))
                          .toList(),
                    )
                  : Text(
                      "No interests added yet",
                      style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            /// GALLERY
            _buildGallerySection(isDark, galleryImages),
            const SizedBox(height: 86),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark, dynamic p) {
    final hasLocation = _hasText((p.location ?? '').toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${p.userName}, ${p.age}",
            style: AppTextStyles.headingLarge(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          if (hasLocation) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 17,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    p.location,
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? AppColors.inputFillDark : AppColors.primary5,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              p.isActiveNow == true ? "🟢 Active now" : "⚪ Offline",
              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: p.isActiveNow == true
                    ? AppColors.green
                    : (isDark ? AppColors.textHintDark : AppColors.textHint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= GALLERY =================

  Widget _buildGallerySection(bool isDark, List<String> images) {
    return _buildSection(
      title: "Photos",
      isDark: isDark,
      child: images.isEmpty
          ? Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputFillDark : AppColors.primary5,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  "No gallery photos added yet",
                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                CarouselSlider.builder(
                  itemCount: images.length,
                  options: CarouselOptions(
                    height: 250,
                    viewportFraction: 1,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: images.length > 1,
                    autoPlay: images.length > 1,
                    autoPlayInterval: const Duration(seconds: 3),
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentGalleryIndex = index;
                      });
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildImage(images[index]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isActive = currentGalleryIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: isActive ? AppGradients.primary : null,
                        color: isActive
                            ? null
                            : (isDark
                                  ? AppColors.inputFillDark
                                  : AppColors.primary5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    );
                  }),
                ),
              ],
            ),
    );
  }
  // ================= COMMON UI =================

  Widget _buildInfoCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return _buildSection(
      title: title,
      isDark: isDark,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium(
                isDark: isDark,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headingMedium(
              isDark: isDark,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _chip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputFillDark : AppColors.primary5,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= IMAGE =================

  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) return _placeholderImage();

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    if (File(imagePath).existsSync()) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    return _placeholderImage();
  }

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
        child: Icon(Icons.person, size: 90, color: AppColors.white),
      ),
    );
  }

  bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
