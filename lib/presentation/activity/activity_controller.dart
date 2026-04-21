import 'package:get/get.dart';
import 'package:zuno_application/core/services/auth_service.dart';
import 'package:zuno_application/data/sources/remote/activity_api.dart';
import 'package:zuno_application/presentation/home/home_controller.dart'; // DatingProfile model

class ActivityController extends GetxController {
  final isLoading = true.obs;
  final hasUnseenUpdates = false.obs;
  final AuthService _authService = AuthService();
  final ActivityApi _activityApi = ActivityApi();
  final RxSet<String> _seenActivityKeys = <String>{}.obs;

  // Likes Tab Data
  final likedProfiles = <DatingProfile>[].obs;

  // Matches Tab Data (new)
  final matchedProfiles = <DatingProfile>[].obs;

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
    final hasUnseenMatches =
        matchedProfiles.any((p) => !isActivitySeen("match", p));
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

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      final receivedLikes = await _activityApi.getReceivedLikes(token);
      final matches = await _activityApi.getMatches(token);

      final likesData = receivedLikes
          .map(_mapActivityProfile)
          .whereType<DatingProfile>()
          .toList();

      final matchesData = matches
          .map(_mapActivityProfile)
          .whereType<DatingProfile>()
          .toList();

      likedProfiles.assignAll(likesData);
      matchedProfiles.assignAll(matchesData);
      hasUnseenUpdates.value = _hasUnseenItems();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  DatingProfile? _mapActivityProfile(dynamic raw) {
    if (raw is! Map) return null;

    final item = Map<String, dynamic>.from(raw);

    // Matches payloads are often nested (e.g. matchedUser/user/targetUser).
    final nestedUser = _firstMap([
      item["matchedUser"],
      item["user"],
      item["targetUser"],
      item["profile"],
    ]);
    final source = nestedUser ?? item;

    final image =
        source["image"]?.toString() ??
        source["profileImage"]?.toString() ??
        item["image"]?.toString() ??
        "";
    final distanceKm =
        source["distanceKm"]?.toString() ?? item["distanceKm"]?.toString() ?? "";

    final interestsRaw = source["interests"] ?? item["interests"];
    final interests = interestsRaw is List
        ? interestsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return DatingProfile(
      id:
          source["userId"]?.toString() ??
          source["_id"]?.toString() ??
          item["userId"]?.toString() ??
          item["_id"]?.toString() ??
          "",
      userName: source["name"]?.toString() ?? item["name"]?.toString() ?? "",
      age: (source["age"] ?? item["age"] ?? "").toString(),
      bio: source["bio"]?.toString() ?? item["bio"]?.toString() ?? "",
      location:
          source["locationName"]?.toString() ??
          source["location"]?.toString() ??
          item["locationName"]?.toString() ??
          item["location"]?.toString() ??
          "",
      interests: interests,
      profileImageUrl: image,
      isActiveNow: true,
      distance: distanceKm.isNotEmpty ? "📍 $distanceKm km" : "",
      imageUrls: image.isNotEmpty ? [image] : [],
      gender: source["gender"]?.toString() ?? item["gender"]?.toString(),
      lookingFor:
          source["lookingFor"]?.toString() ?? item["lookingFor"]?.toString(),
    );
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
