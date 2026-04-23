// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:nearly/core/services/auth_service.dart';
import 'package:nearly/data/sources/remote/home_api.dart';


class DatingProfile {
  final String id;
  final String userName;
  final String age;
  final String bio;
  final String location;
  final List<String> interests;
  final String profileImageUrl; 
  final bool isActiveNow;
  final String distance;
  final List<String> imageUrls; 
  final String? gender;
  final String? lookingFor;

  DatingProfile({
    required this.id,
    required this.userName,
    required this.age,
    required this.bio,
    required this.location,
    required this.interests,
    required this.profileImageUrl,
    required this.isActiveNow,
    required this.distance,
    required this.imageUrls,
    this.gender,
    this.lookingFor,
  });

  DatingProfile copyWith({
    String? id,
    String? userName,
    String? age,
    String? bio,
    String? location,
    List<String>? interests,
    String? profileImageUrl,
    bool? isActiveNow,
    String? distance,
    List<String>? imageUrls,
    String? gender,
    String? lookingFor,
  }) {
    return DatingProfile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActiveNow: isActiveNow ?? this.isActiveNow,
      distance: distance ?? this.distance,
      imageUrls: imageUrls ?? this.imageUrls,
      gender: gender ?? this.gender,
      lookingFor: lookingFor ?? this.lookingFor,
    );
  }
}

class HomeController extends GetxController {
  final isLoading = true.obs;
  final AuthService _authService = AuthService();
  final HomeApi _homeApi = HomeApi();

  final CardSwiperController cardSwiperController = CardSwiperController();

  /// ✅ master list (never changes)
  final allProfiles = <DatingProfile>[].obs;

  /// UI list (used for swiping)
  final profiles = <DatingProfile>[].obs;

  /// button press animation states
  final isDislikePressed = false.obs;
  final isStarPressed = false.obs;
  final isLikePressed = false.obs;
  final isBoostPressed = false.obs;

  DatingProfile? get currentProfile =>
      profiles.isNotEmpty ? profiles.first : null;

  bool get hasProfiles => profiles.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  @override
  void onClose() {
    cardSwiperController.dispose();
    super.onClose();
  }

  Future<void> refreshPage() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    await loadHomeData();
  }

  Future<void> loadHomeData() async {
    profiles.clear();
    allProfiles.clear();
    isLoading.value = true;

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);

      if (token == null) throw "Token not found";

      final feedData = await _homeApi.getDiscoveryFeed(token);

      final mappedProfiles = feedData.map((item) {
        final distanceKm = (item["distanceKm"] ?? 0).toString();
        final image = item["image"]?.toString() ?? "";

        return DatingProfile(
          id: item["userId"]?.toString() ?? "",
          userName: item["name"]?.toString() ?? "",
          age: (item["age"] ?? "").toString(),
          bio: item["bio"]?.toString() ?? "",
          location: "",
          interests: List<String>.from(item["interests"] ?? []),
          profileImageUrl: image,
          isActiveNow: true,
          distance: "📍 $distanceKm km",
          imageUrls: image.isNotEmpty ? [image] : [],
          gender: null,
          lookingFor: null,
        );
      }).toList();

      allProfiles.assignAll(mappedProfiles);
      profiles.assignAll(mappedProfiles);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSwipeLeft(int index) {
    _sendActionForIndex(index, "dislike");
    _syncAfterSwipe();
  }

  void onSwipeRight(int index) {
    _sendActionForIndex(index, "like");
    _syncAfterSwipe();
  }

  void onSwipeUp(int index) {
    _syncAfterSwipe();
  }

  void _syncAfterSwipe() {
    if (profiles.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 40), () {
        if (profiles.isNotEmpty) {
          profiles.removeAt(0);
          profiles.refresh();
        }
      });
    }
  }

  void swipeLeft() {
    if (!hasProfiles || isLoading.value) return;
    cardSwiperController.swipe(CardSwiperDirection.left);
  }

  void swipeRight() {
    if (!hasProfiles || isLoading.value) return;
    cardSwiperController.swipe(CardSwiperDirection.right);
  }

  void swipeUp() {
    if (!hasProfiles || isLoading.value) return;
    cardSwiperController.swipe(CardSwiperDirection.top);
  }

  Future<void> pressDislike() async {
    if (!hasProfiles) return;
    isDislikePressed.value = true;
    await Future.delayed(const Duration(milliseconds: 120));
    isDislikePressed.value = false;
    swipeLeft();
  }

  Future<void> pressStar() async {
    if (!hasProfiles) return;
    isStarPressed.value = true;
    await Future.delayed(const Duration(milliseconds: 120));
    isStarPressed.value = false;
    swipeUp();
  }

  Future<void> pressLike() async {
    if (!hasProfiles) return;
    isLikePressed.value = true;
    await Future.delayed(const Duration(milliseconds: 120));
    isLikePressed.value = false;
    swipeRight();
  }

  Future<void> pressBoost() async {
    if (!hasProfiles) return;
    isBoostPressed.value = true;
    await Future.delayed(const Duration(milliseconds: 120));
    isBoostPressed.value = false;
    swipeUp();
  }

  Future<void> _sendActionForIndex(int index, String action) async {
    try {
      if (index < 0 || index >= profiles.length) return;
      final targetUserId = profiles[index].id;
      if (targetUserId.isEmpty) return;
      print("HomeController: swipe action -> $action for userId=$targetUserId");

      log(
        "Triggering $action for index=$index targetUserId=$targetUserId",
        name: "HomeController",
      );

      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) {
        print("HomeController: token is null, API not called for $action");
        log(
          "Skipping $action: Firebase token is null",
          name: "HomeController",
        );
        return;
      }

      await _homeApi.sendDiscoveryAction(
        token: token,
        targetUserId: targetUserId,
        action: action,
      );
      print("HomeController: $action API call completed for $targetUserId");

      log(
        "$action action submitted successfully for $targetUserId",
        name: "HomeController",
      );
    } catch (e) {
      print("HomeController: $action API error -> $e");
      log("Failed to submit $action action: $e", name: "HomeController");
      // Keep swipe flow smooth even if action API fails.
    }
  }
}