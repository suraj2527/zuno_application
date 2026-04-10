// ignore_for_file: unused_local_variable

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

class DatingProfile {
  final String id;
  final String userName;
  final String age;
  final String bio;
  final String location;
  final List<String> interests;
  final String profileImageUrl; // ✅ single main profile image
  final bool isActiveNow;
  final String distance;
  final List<String> imageUrls; // ✅ gallery images
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

    await Future.delayed(const Duration(seconds: 2));

    final data = [
      DatingProfile(
        id: "1",
        userName: "Maya",
        age: "23",
        bio: "Coffee lover, music addict and weekend explorer.",
        location: "New Delhi, India",
        interests: ["🎵 Music", "✈️ Travel", "☕ Coffee", "🎬 Movies"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80",
        imageUrls: [
          "https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop",
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=600&auto=format&fit=crop",
          "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=600&auto=format&fit=crop",
        ],
        isActiveNow: true,
        distance: "📍 2.1 km",
        gender: "Woman",
        lookingFor: "Long-term Relationship",
      ),
      DatingProfile(
        id: "2",
        userName: "Priya",
        age: "24",
        bio: "Into books, long drives and good conversations.",
        location: "Gurugram, India",
        interests: ["📚 Reading", "✈️ Travel", "🍕 Foodie", "🎵 Music"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop",
        imageUrls: [
          "https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop",
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=600&auto=format&fit=crop",
          "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?q=80&w=600&auto=format&fit=crop",
        ],
        isActiveNow: false,
        distance: "📍 4.3 km",
        gender: "Woman",
        lookingFor: "Casual Dating",
      ),
    ];

    allProfiles.assignAll(data);
    profiles.assignAll(data);

    isLoading.value = false;
  }

  void onSwipeLeft(int index) {
    _syncAfterSwipe();
  }

  void onSwipeRight(int index) {
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
}