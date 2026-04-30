import 'dart:async';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:Nearly/core/services/auth_service.dart';
import 'package:Nearly/data/sources/remote/activity_api.dart';
import 'package:Nearly/data/sources/remote/home_api.dart'; // ✅ ADD
import 'package:Nearly/presentation/home/home_controller.dart'; // DatingProfile model

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
      print("===== GET RECEIVED LIKES API RESPONSE =====");
      print(receivedLikes);
      print("===== GET MATCHES API RESPONSE =====");
      print(matches);

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
  Future<void> likeProfile(String profileId) async {
    if (likedProfileIds.contains(profileId)) return;

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      final success = await _homeApi.sendDiscoveryAction(
        token: token,
        targetUserId: profileId,
        action: 'like',
      );

      if (success) {
        likedProfileIds.add(profileId);
        Get.snackbar(
          "Success",
          "Profile liked!",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
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
