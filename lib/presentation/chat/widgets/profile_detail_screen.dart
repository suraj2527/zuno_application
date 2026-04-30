import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/core/routes/app_routes.dart';
import 'package:Nearly/core/services/auth_service.dart';
import 'package:Nearly/data/model/chat/chat_preview_model.dart';
import 'package:Nearly/data/sources/remote/home_api.dart';
import 'package:Nearly/presentation/home/home_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final dynamic profile;
  final String heroTag;
  final bool isFromMatches;
  final bool isFromChat;

  const ProfileDetailsScreen({
    super.key,
    required this.profile,
    required this.heroTag,
    this.isFromMatches = false,
    this.isFromChat = false,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final HomeApi _homeApi = HomeApi();
  final AuthService _authService = AuthService();

  int currentGalleryIndex = 0;
  bool isLikeLoading = false;

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
        backgroundColor: isDark ? AppColors.scaffoldDark : const Color(0xFFF8F8FB),
        body: const Center(child: Text("Profile not found")),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : const Color(0xFFF8F8FB),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(p),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileInfo(isDark, p),
                      const SizedBox(height: 32),
                      
                      _buildElegantSectionTitle('About Me'),
                      _buildAboutMeCard(isDark, p),
                      
                      const SizedBox(height: 32),
                      
                      _buildElegantSectionTitle('Bio'),
                      _buildBioCard(isDark, p.bio ?? ""),
                      
                      const SizedBox(height: 32),
                      
                      _buildElegantSectionTitle('Interests'),
                      _buildInterestsCard(isDark, (p.interests as List<dynamic>?)?.map((e) => e.toString()).toList() ?? []),
                      
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildConditionalButton(isDark, p),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(dynamic p) {
    List<String> images = [];
    if (p.imageUrls is List) {
      images = (p.imageUrls as List).map((e) => e.toString()).toList();
    }
    
    if (images.isEmpty && p.profileImageUrl != null) {
      images.add(p.profileImageUrl.toString());
    }

    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _appBarCircleButton(Icons.arrow_back_ios_new_rounded, Get.back),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _appBarCircleButton(Icons.more_horiz_rounded, () {}),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (images.length <= 1)
              Hero(
                tag: widget.heroTag,
                child: _buildImage(images.isNotEmpty ? images.first : p.profileImageUrl),
              )
            else
              CarouselSlider.builder(
                itemCount: images.length,
                options: CarouselOptions(
                  height: 450,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  onPageChanged: (index, _) => setState(() => currentGalleryIndex = index),
                ),
                itemBuilder: (context, index, _) {
                  return Hero(
                    tag: index == 0 ? widget.heroTag : "gallery_${widget.heroTag}_$index",
                    child: _buildImage(images[index]),
                  );
                },
              ),
            
            // Indicators
            if (images.length > 1)
              Positioned(
                top: MediaQuery.of(Get.context!).padding.top + 20,
                left: 60,
                right: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isActive = currentGalleryIndex == index;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 3,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black12, Colors.black54],
                      stops: [0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildProfileInfo(bool isDark, dynamic p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${p.userName}, ${p.age}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            if (p.isActiveNow == true)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              p.location != null && p.location.isNotEmpty ? p.location : "Nearby",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElegantSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAboutMeCard(bool isDark, dynamic p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline_rounded, "Gender", p.gender ?? "Not specified"),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
          _buildInfoRow(Icons.favorite_border_rounded, "Looking for", p.lookingFor ?? "Not specified"),
          if (p is DatingProfile && p.religion != null) ...[
            const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
            _buildInfoRow(Icons.auto_awesome_rounded, "Religion", p.religion!),
          ],
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 48),
          _buildInfoRow(Icons.location_on_outlined, "Location", p.location ?? "Nearby"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w400)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBioCard(bool isDark, String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        bio.isNotEmpty ? bio : "No bio added yet.",
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInterestsCard(bool isDark, List<String> interests) {
    if (interests.isEmpty) {
      return const Text("No interests added yet", style: TextStyle(color: Colors.black38, fontSize: 14));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            interest,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildConditionalButton(bool isDark, dynamic p) {
    if (widget.isFromChat) return const SizedBox.shrink();
    final bool isChat = widget.isFromMatches;
    
    return GestureDetector(
      onTap: isLikeLoading ? null : () {
        if (isChat) {
          final String? matchId = p is DatingProfile ? p.matchId : null;
          if (matchId != null && matchId.isNotEmpty) {
            final chatPreview = ChatPreviewModel(
              id: matchId,
              name: p.userName,
              imageUrl: p.profileImageUrl,
              lastMessage: "",
              time: "Now",
              isOnline: p.isActiveNow,
              isTyping: false,
              unreadCount: 0,
              isSeen: false,
              isDelivered: false,
              isArchived: false,
            );
            Get.toNamed(Routes.CHAT_DETAIL, arguments: chatPreview);
          } else {
            Get.back();
          }
        } else {
          _likeProfile();
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLikeLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isChat ? Icons.chat_bubble_rounded : Icons.favorite_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      isChat ? "Start Chat" : "Like Profile",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      if (mounted) setState(() => isLikeLoading = false);
    }
  }

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
