import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Dashboard/home/home_controller.dart'; // DatingProfile model

class ActivityController extends GetxController {
  final isLoading = true.obs;

  // Likes Tab Data
  final likedProfiles = <DatingProfile>[].obs;

  // Matches Tab Data (new)
  final matchedProfiles = <DatingProfile>[].obs;

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

    // Clear previous data
    likedProfiles.clear();
    matchedProfiles.clear();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // ==================== LIKES DATA ====================
    final List<DatingProfile> likesData = [
      DatingProfile(
        id: "101",
        userName: "Sophie",
        age: "24",
        bio: "Coffee lover & weekend explorer",
        location: "New Delhi, India",
        interests: ["Coffee", "Travel", "Music"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80",
        isActiveNow: true,
        distance: "📍 2.1 km",
      ),
      DatingProfile(
        id: "102",
        userName: "Emma",
        age: "26",
        bio: "Music addict",
        location: "Mumbai, India",
        interests: ["Music", "Dance"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80",
        isActiveNow: false,
        distance: "📍 5.8 km",
      ),
      DatingProfile(
        id: "103",
        userName: "Alex",
        age: "27",
        bio: "Travel enthusiast",
        location: "Bangalore, India",
        interests: ["Travel", "Photography"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80",
        isActiveNow: true,
        distance: "📍 12 km",
      ),
      DatingProfile(
        id: "104",
        userName: "Priya",
        age: "25",
        bio: "Book lover",
        location: "Hyderabad, India",
        interests: ["Books", "Writing"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop",
        isActiveNow: false,
        distance: "📍 4.3 km",
      ),
      DatingProfile(
        id: "105",
        userName: "Rahul",
        age: "29",
        bio: "Fitness & movies",
        location: "Chennai, India",
        interests: ["Fitness", "Movies"],
        profileImageUrl:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80",
        isActiveNow: true,
        distance: "📍 8.7 km",
      ),
    ];

    likedProfiles.assignAll(likesData);

    // ==================== MATCHES DATA ====================
    // You can keep this empty initially or add some matches
    final List<DatingProfile> matchesData = [
      // Example: Uncomment when you want to show matches
      
      DatingProfile(
        id: "201",
        userName: "Mia",
        age: "24",
        bio: "Mutual Match ❤️",
        location: "New Delhi, India",
        interests: ["Art", "Travel"],
        profileImageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80",
        isActiveNow: true,
        distance: "📍 3.2 km",
      ),
      
    ];

    matchedProfiles.assignAll(matchesData);

    isLoading.value = false;
  }
}