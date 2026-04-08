import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';

class DatingProfile {
  final String userName;
  final String age;
  final String bio;
  final String location;
  final List<String> interests;
  final String profileImageUrl;
  final bool isActiveNow;
  final String distance;

  DatingProfile({
    required this.userName,
    required this.age,
    required this.bio,
    required this.location,
    required this.interests,
    required this.profileImageUrl,
    required this.isActiveNow,
    required this.distance,
  });
}

class HomeController extends GetxController {
  final isLoading = true.obs;

  final CardSwiperController cardSwiperController = CardSwiperController();

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
    await Future.delayed(const Duration(seconds: 2));

    profiles.assignAll([
      DatingProfile(
        userName: "Ananya",
        age: "23",
        bio: "Coffee lover, music addict and weekend explorer.",
        location: "New Delhi, India",
        interests: ["Music", "Travel", "Coffee", "Movies"],
        profileImageUrl: "",
        isActiveNow: true,
        distance: "📍 2.1 km",
      ),
      DatingProfile(
        userName: "Riya",
        age: "24",
        bio: "Into books, long drives and good conversations.",
        location: "Gurugram, India",
        interests: ["Books", "Travel", "Food", "Music"],
        profileImageUrl: "",
        isActiveNow: false,
        distance: "📍 4.3 km",
      ),
      DatingProfile(
        userName: "Kashish",
        age: "22",
        bio: "Fitness, fashion and spontaneous plans.",
        location: "Noida, India",
        interests: ["Gym", "Fashion", "Dance", "Coffee"],
        profileImageUrl: "",
        isActiveNow: true,
        distance: "📍 3.0 km",
      ),
    ]);

    isLoading.value = false;
  }

  void onSwipeLeft(int index) {
    if (profiles.isNotEmpty) {
      final swipedProfile = profiles.first;
      print("Rejected: ${swipedProfile.userName}");
    }
    _syncAfterSwipe();
  }

  void onSwipeRight(int index) {
    if (profiles.isNotEmpty) {
      final swipedProfile = profiles.first;
      print("Liked: ${swipedProfile.userName}");
    }
    _syncAfterSwipe();
  }

  void onSwipeUp(int index) {
    if (profiles.isNotEmpty) {
      final swipedProfile = profiles.first;
      print("Super liked: ${swipedProfile.userName}");
    }
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

  /// button press animation helpers
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
