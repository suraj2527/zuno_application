import 'package:get/get.dart';
import 'package:zuno_application/core/services/auth_service.dart';
import 'package:zuno_application/data/sources/remote/activity_api.dart';
import 'package:zuno_application/presentation/home/home_controller.dart'; // DatingProfile model

class ActivityController extends GetxController {
  final isLoading = true.obs;
  final hasUnseenUpdates = false.obs;
  final AuthService _authService = AuthService();
  final ActivityApi _activityApi = ActivityApi();

  // Likes Tab Data
  final likedProfiles = <DatingProfile>[].obs;

  // Matches Tab Data (new)
  final matchedProfiles = <DatingProfile>[].obs;

  bool get hasActivityUpdates =>
      likedProfiles.isNotEmpty || matchedProfiles.isNotEmpty;

  void markUpdatesAsSeen() {
    hasUnseenUpdates.value = false;
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

      final likesData = receivedLikes.map((item) {
        final image = item["image"]?.toString() ?? "";
        final distanceKm = item["distanceKm"]?.toString() ?? "";

        return DatingProfile(
          id: item["userId"]?.toString() ?? "",
          userName: item["name"]?.toString() ?? "",
          age: (item["age"] ?? "").toString(),
          bio: item["bio"]?.toString() ?? "",
          location: item["location"]?.toString() ?? "",
          interests: List<String>.from(item["interests"] ?? []),
          profileImageUrl: image,
          isActiveNow: true,
          distance: distanceKm.isNotEmpty ? "📍 $distanceKm km" : "",
          imageUrls: image.isNotEmpty ? [image] : [],
          gender: item["gender"]?.toString(),
          lookingFor: item["lookingFor"]?.toString(),
        );
      }).toList();

      final matchesData = matches.map((item) {
        final image = item["image"]?.toString() ?? "";
        final distanceKm = item["distanceKm"]?.toString() ?? "";

        return DatingProfile(
          id: item["userId"]?.toString() ?? "",
          userName: item["name"]?.toString() ?? "",
          age: (item["age"] ?? "").toString(),
          bio: item["bio"]?.toString() ?? "",
          location: item["location"]?.toString() ?? "",
          interests: List<String>.from(item["interests"] ?? []),
          profileImageUrl: image,
          isActiveNow: true,
          distance: distanceKm.isNotEmpty ? "📍 $distanceKm km" : "",
          imageUrls: image.isNotEmpty ? [image] : [],
          gender: item["gender"]?.toString(),
          lookingFor: item["lookingFor"]?.toString(),
        );
      }).toList();

      likedProfiles.assignAll(likesData);
      matchedProfiles.assignAll(matchesData);
      hasUnseenUpdates.value = hasActivityUpdates;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
