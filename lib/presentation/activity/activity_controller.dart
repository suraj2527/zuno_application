import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:Nearly/core/routes/app_routes.dart';
import 'package:Nearly/core/services/auth_service.dart';
import 'package:Nearly/data/model/chat/chat_preview_model.dart';
import 'package:Nearly/data/sources/remote/activity_api.dart';
import 'package:Nearly/data/sources/remote/home_api.dart';
import 'package:Nearly/presentation/chat/chat_controller.dart';
import 'package:Nearly/presentation/home/home_controller.dart';
import 'package:Nearly/presentation/profile/profile_controller.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_gradients.dart';
import 'package:Nearly/shared/utils/app_notifications.dart';
import 'package:Nearly/shared/widgets/common/nearly_image.dart';

class ActivityController extends GetxController {
  final isLoading = true.obs;
  final hasUnseenUpdates = false.obs;
  final AuthService _authService = AuthService();
  final ActivityApi _activityApi = ActivityApi();
  final HomeApi _homeApi = HomeApi(); // ✅ ADD
  final RxSet<String> _seenActivityKeys = <String>{}.obs;
  final RxSet<String> likedProfileIds = <String>{}.obs; // ✅ Track likes locally

  // Likes Tab Data
  final likedProfiles = <DatingProfile>[].obs;

  // Matches Tab Data (new)
  final matchedProfiles = <DatingProfile>[].obs;

  Timer? _refreshTimer;

  bool get hasActivityUpdates =>
      likedProfiles.isNotEmpty || matchedProfiles.isNotEmpty;

  String _activityKey(String type, String profileId) => "$type::$profileId";

  bool isActivitySeen(String type, DatingProfile profile) {
    return _seenActivityKeys.contains(_activityKey(type, profile.id));
  }

  void markActivitySeen(String type, DatingProfile profile) {
    _seenActivityKeys.add(_activityKey(type, profile.id));
    hasUnseenUpdates.value = _hasUnseenItems();
  }

  bool _hasUnseenItems() {
    final hasUnseenLikes = likedProfiles.any((p) => !isActivitySeen("like", p));
    final hasUnseenMatches = matchedProfiles.any(
      (p) => !isActivitySeen("match", p),
    );
    return hasUnseenLikes || hasUnseenMatches;
  }

  void markAllActivitiesSeen() {
    for (final p in likedProfiles) {
      _seenActivityKeys.add(_activityKey("like", p.id));
    }
    for (final p in matchedProfiles) {
      _seenActivityKeys.add(_activityKey("match", p.id));
    }
    hasUnseenUpdates.value = false;
  }

  void markUpdatesAsSeen() {
    markAllActivitiesSeen();
  }

  @override
  void onInit() {
    super.onInit();
    loadActivityData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadActivityDataSilently();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> refreshActivity() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    await loadActivityData();
  }

  Future<void> loadActivityData() async {
    isLoading.value = true;
    likedProfiles.clear();
    matchedProfiles.clear();
    await _fetchData();
    isLoading.value = false;
  }

  Future<void> _loadActivityDataSilently() async {
    if (isLoading.value) return; // Don't interrupt manual refresh
    await _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      final receivedLikes = await _activityApi.getReceivedLikes(token);
      final matches = await _activityApi.getMatches(token);

      final likesData = <DatingProfile>[];
      for (var item in receivedLikes) {
        final p = await _mapActivityProfileAsync(item);
        if (p != null) likesData.add(p);
      }

      final matchesData = <DatingProfile>[];
      for (var item in matches) {
        final p = await _mapActivityProfileAsync(item);
        if (p != null) matchesData.add(p);
      }

      // ✅ Filter out liked profiles that are already matched
      final matchedIds = matchesData.map((m) => m.id).toSet();
      final filteredLikes = likesData
          .where((l) => !matchedIds.contains(l.id))
          .toList();

      likedProfiles.assignAll(filteredLikes);
      matchedProfiles.assignAll(matchesData);
      hasUnseenUpdates.value = _hasUnseenItems();
    } catch (e) {
      // Silently fail on background refresh
    }
  }

  // ✅ ADD LIKE FUNCTIONALITY
  Future<void> likeProfile(DatingProfile profile) async {
    final profileId = profile.id;
    if (likedProfileIds.contains(profileId)) return;

    likedProfileIds.add(profileId);
    // Optimistically remove from likes so it instantly updates UI
    likedProfiles.removeWhere((p) => p.id == profileId);
    
    // Any 'like' from the Activity Tab (Likes Section) is guaranteed to be a Match
    // Optimistically show the Match Dialog immediately.
    _showMatchDialog(profile);

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      // Perform the like action
      final response = await _homeApi.sendDiscoveryAction(
        token: token,
        targetUserId: profileId,
        action: 'like',
      );

      // Extract matchId if present
      String? newMatchId;
      if (response != null) {
        final dynamic matchObj = response['match'] ?? response['data']?['match'];
        final matchData = matchObj ?? response;
        newMatchId = matchData['matchId'] ?? matchData['_id'] ?? matchData['conversationId'] ?? matchData['id'];
      }

      // Add to matches optimistically with the new matchId (if any) before refreshing
      final updatedProfile = profile.copyWith(matchId: newMatchId?.toString());
      if (!matchedProfiles.any((m) => m.id == profileId)) {
        matchedProfiles.insert(0, updatedProfile);
      }

      // Refresh background data to synchronize everything
      loadActivityData();
      
    } catch (e) {
      AppNotifications.showError("Failed to match. Please try again.");
      likedProfileIds.remove(profileId);
      loadActivityData(); // Refresh to restore state
    }
  }

  void _showMatchDialog(DatingProfile matchedUser) {
    final profileController = Get.find<ProfileController>();
    final myProfile = profileController.profile.value;

    Get.dialog(
      _MatchDialogWidget(
        myProfile: myProfile,
        matchedUser: matchedUser,
        onStartChat: () {
          Get.back();
          _navigateToChat(matchedUser);
        },
      ),
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeOutBack,
    );
  }

  void _navigateToChat(DatingProfile p) async {
    String matchId = p.matchId ?? '';

    if (matchId.isEmpty) {
      final found = matchedProfiles.firstWhereOrNull((m) => m.id == p.id);
      matchId = found?.matchId ?? '';
    }

    if (matchId.isEmpty) {
      AppNotifications.showSuccess('Preparing chat...');
      for (int i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        final found = matchedProfiles.firstWhereOrNull((m) => m.id == p.id);
        if (found != null && found.matchId != null && found.matchId!.isNotEmpty) {
          matchId = found.matchId!;
          break;
        }
      }
    }

    if (matchId.isEmpty) {
      AppNotifications.showError('No chat found for this match');
      return;
    }

    ChatPreviewModel? existingChat;
    if (Get.isRegistered<ChatController>()) {
      final chatController = Get.find<ChatController>();
      try {
        existingChat = chatController.chatList.firstWhere(
          (c) => c.id == matchId || c.matchId == matchId,
        );
      } catch (_) {
        existingChat = null;
      }
    }

    final chatPreview = existingChat ?? ChatPreviewModel(
      id: matchId,
      matchId: matchId,
      name: p.userName,
      imageUrl: p.profileImageUrl,
      lastMessage: '',
      time: 'Now',
      isOnline: true,
      isTyping: false,
      unreadCount: 0,
      isSeen: true,
      isDelivered: true,
      isArchived: false,
    );

    Get.toNamed(Routes.CHAT_DETAIL, arguments: chatPreview);
  }

  Future<DatingProfile?> _mapActivityProfileAsync(dynamic raw) async {
    if (raw is! Map) return null;

    final item = Map<String, dynamic>.from(raw);

    // Matches payloads are often nested (e.g. matchedUser/user/targetUser).
    final profile =
        _firstMap([
          item["profile"],
          item["matchedUser"],
          item["user"],
          item["fromUser"], // ✅ ADD
          item["targetUser"],
        ]) ??
        item;

    // Extract Images
    final List<dynamic> imagesData =
        (profile["images"] ?? item["images"]) is List
        ? List<dynamic>.from(profile["images"] ?? item["images"])
        : [];

    String primaryImage = "";
    List<String> allImages = [];

    if (imagesData.isNotEmpty) {
      allImages = imagesData
          .map(
            (img) =>
                img is Map ? (img["url"]?.toString() ?? "") : img.toString(),
          )
          .where((url) => url.isNotEmpty)
          .toSet()
          .toList();

      final primaryObj = imagesData.firstWhere(
        (img) => img is Map && img["isPrimary"] == true,
        orElse: () => imagesData.first,
      );
      primaryImage = (primaryObj is Map
          ? (primaryObj["url"]?.toString() ?? "")
          : primaryObj.toString());

      if (allImages.contains(primaryImage)) {
        allImages.remove(primaryImage);
        allImages.insert(0, primaryImage);
      } else if (primaryImage.isNotEmpty) {
        allImages.insert(0, primaryImage);
      }
      allImages = allImages.take(3).toList();
    } else {
      // Fallback
      primaryImage =
          item["image"]?.toString() ??
          profile["image"]?.toString() ??
          profile["profileImage"]?.toString() ??
          "";
      allImages = primaryImage.isNotEmpty ? [primaryImage] : [];
    }

    final interestsRaw = profile["interests"] ?? item["interests"];
    final interests = interestsRaw is List
        ? interestsRaw
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    // Handle Location Mapping
    String locationName =
        profile["locationName"]?.toString() ??
        item["locationName"]?.toString() ??
        "";
    if (locationName.isEmpty) {
      final loc = profile["location"] ?? item["location"];
      if (loc is Map) {
        final lat = loc["lat"] ?? loc["latitude"];
        final lng = loc["lng"] ?? loc["longitude"];
        if (lat is num && lng is num) {
          locationName = await _getAddressFromLatLng(
            lat.toDouble(),
            lng.toDouble(),
          );
        }
      }
    }

    return DatingProfile(
      id:
          item["userId"]?.toString() ??
          profile["userId"]?.toString() ??
          profile["_id"]?.toString() ??
          item["_id"]?.toString() ??
          "",
      userName: profile["name"]?.toString() ?? item["name"]?.toString() ?? "",
      age: (profile["age"] ?? item["age"] ?? "").toString(),
      bio: profile["bio"]?.toString() ?? item["bio"]?.toString() ?? "",
      location: locationName,
      interests: interests,
      profileImageUrl: primaryImage,
      isActiveNow: true,
      distance: "",
      imageUrls: allImages,
      gender: profile["gender"]?.toString() ?? item["gender"]?.toString(),
      lookingFor:
          profile["lookingFor"]?.toString() ?? item["lookingFor"]?.toString(),
      matchId:
          item["conversationId"]?.toString() ??
          item["matchId"]?.toString() ??
          item["chatId"]?.toString() ??
          item["_id"]?.toString(),
    );
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      }
      return "";
    } catch (e) {
      return "";
    }
  }

  Map<String, dynamic>? _firstMap(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }
    return null;
  }
}

class _MatchDialogWidget extends StatefulWidget {
  final DatingProfile? myProfile;
  final DatingProfile matchedUser;
  final VoidCallback onStartChat;

  const _MatchDialogWidget({
    required this.myProfile,
    required this.matchedUser,
    required this.onStartChat,
  });

  @override
  State<_MatchDialogWidget> createState() => _MatchDialogWidgetState();
}

class _MatchDialogWidgetState extends State<_MatchDialogWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                // Match Title
                ShaderMask(
                  shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                  child: const Text(
                    "Match Found! 🎉",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You and ${widget.matchedUser.userName} liked each other",
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Avatars
                SizedBox(
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // My Avatar (Left)
                      Transform.translate(
                        offset: const Offset(-40, 0),
                        child: _buildMatchAvatar(widget.myProfile?.profileImageUrl ?? ""),
                      ),
                      // Matched User Avatar (Right)
                      Transform.translate(
                        offset: const Offset(40, 0),
                        child: _buildMatchAvatar(widget.matchedUser.profileImageUrl),
                      ),
                      // Heart Icon in middle
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 36),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: widget.onStartChat,
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Start Chat",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          "Keep Exploring",
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        
        // Confetti Overlay
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              Color(0xFF8B5CF6), // primaryDark replacement / purple
              Colors.pink,
              Colors.orange,
              Colors.lightBlue,
            ],
            createParticlePath: drawStar,
            numberOfParticles: 25,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  Widget _buildMatchAvatar(String url) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: url.isNotEmpty
            ? NearlyImage(
                imageUrl: url, 
                fit: BoxFit.cover,
                errorWidget: _avatarPlaceholder(),
              )
            : _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: const Icon(Icons.person, color: AppColors.primary, size: 40),
    );
  }
}
