import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zuno_application/core/routes/app_routes.dart';
import 'package:zuno_application/core/services/auth_service.dart';
import 'package:zuno_application/presentation/home/home_controller.dart';
import 'package:zuno_application/data/sources/remote/user_api.dart'; // ✅ ADD

class ProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  final UserApi _userApi = UserApi(); 
  

  // ================= PROFILE STATE =================

  final Rxn<DatingProfile> profile = Rxn<DatingProfile>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt currentGalleryIndex = 0.obs;

  // ================= EDIT FORM CONTROLLERS =================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxDouble selectedAge = 24.0.obs;
  final RxString selectedLookingFor = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  final RxString selectedProfileImage = ''.obs;
  final RxList<String> selectedGalleryImages = <String>[].obs;

  // ================= MASTER INTERESTS =================

  final List<String> allInterests = [
    '🎵 Music',
    '🏔️ Hiking',
    '📚 Reading',
    '☕ Coffee',
    '🎮 Gaming',
    '🍕 Foodie',
    '🐶 Dogs',
    '🧘 Yoga',
    '✈️ Travel',
    '🎨 Art',
    '🎬 Movies',
    '🏋️ Fitness',
    '📸 Photography',
    '🍳 Cooking',
  ];

  final List<Map<String, String>> genderOptions = [
    {'emoji': '👩', 'label': 'Woman'},
    {'emoji': '👨', 'label': 'Man'},
    {'emoji': '🧑', 'label': 'Non-binary'},
    {'emoji': '⚡', 'label': 'Genderfluid'},
  ];

  final List<Map<String, String>> lookingForOptions = [
    {
      'emoji': '❤️',
      'title': 'Long-term Relationship',
      'subtitle': 'Looking for something serious',
    },
    {'emoji': '☕', 'title': 'Casual Dating', 'subtitle': 'Go with the flow'},
    {
      'emoji': '🤝',
      'title': 'Friendship',
      'subtitle': 'Just making new friends',
    },
    {
      'emoji': '🌟',
      'title': 'Not sure yet',
      'subtitle': 'Let’s see what happens',
    },
  ];

  DatingProfile? get myProfile => homeController.allProfiles.isNotEmpty
      ? homeController.allProfiles.first
      : null;

  @override
  void onInit() {
    super.onInit();

    /// 🔥 ensure clean state first (important for refresh issue)
    isLoading.value = true;

    Future.delayed(Duration.zero, () {
      loadProfileData();
    });
  }

  // ================= 🔥 UPDATED GET API =================
  Future<void> loadProfileData() async {
    isLoading.value = true;

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);

      if (token == null) throw "Token not found";

      final data = await _userApi.getProfile(token);

      /// 🔥 Extract lat lng
      final lat = data["location"]?["lat"];
      final lng = data["location"]?["lng"];

      String locationName = "";

      if (lat != null && lng != null) {
        try {
          final placemarks = await placemarkFromCoordinates(lat, lng);

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;

            /// 🔥 You can customize this
            locationName =
                "${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
          }
        } catch (e) {
          locationName = "";
        }
      }

      profile.value = DatingProfile(
        id: data["_id"] ?? "",
        userName: data["name"] ?? "",
        age: (data["age"] ?? 24).toString(),
        bio: data["bio"] ?? "",
        location: locationName, // ✅ FIXED
        interests: List<String>.from(data["interests"] ?? []),
        profileImageUrl:
            data["profileImage"] ?? _authService.currentUser?.photoURL ?? "",
        isActiveNow: true,
        distance: "",
        imageUrls: List<String>.from(data["images"] ?? []),
        gender: data["gender"],
        lookingFor: data["lookingFor"],
      );

      nameController.text = data["name"] ?? "";
      bioController.text = data["bio"] ?? "";
      locationController.text = locationName; // ✅ IMPORTANT

      selectedGender.value = data["gender"] ?? "";
      selectedAge.value = (data["age"] ?? 24).toDouble();
      selectedLookingFor.value = data["lookingFor"] ?? "";

      selectedInterests.assignAll(List<String>.from(data["interests"] ?? []));
      selectedGalleryImages.assignAll(List<String>.from(data["images"] ?? []));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  // ================= IMAGE ACTIONS =================

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedProfileImage.value = image.path;
    }
  }

  Future<void> pickGalleryImage() async {
    if (selectedGalleryImages.length >= 3) {
      Get.snackbar(
        "Limit Reached",
        "You can upload maximum 3 gallery photos.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedGalleryImages.add(image.path);
    }
  }

  void removeGalleryImage(int index) {
    if (index < 0 || index >= selectedGalleryImages.length) return;

    selectedGalleryImages.removeAt(index);

    if (currentGalleryIndex.value >= selectedGalleryImages.length &&
        selectedGalleryImages.isNotEmpty) {
      currentGalleryIndex.value = selectedGalleryImages.length - 1;
    } else if (selectedGalleryImages.isEmpty) {
      currentGalleryIndex.value = 0;
    }
  }

  void updateCarouselIndex(int index) {
    currentGalleryIndex.value = index;
  }

  // ================= FORM ACTIONS =================

  void selectGender(String value) {
    selectedGender.value = value;
  }

  void updateAge(double value) {
    selectedAge.value = value.clamp(18.0, 80.0);
  }

  void selectLookingFor(String value) {
    selectedLookingFor.value = value;
  }

  void toggleInterest(String value) {
    if (selectedInterests.contains(value)) {
      selectedInterests.remove(value);
    } else {
      selectedInterests.add(value);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService().signOut();

      final box = GetStorage();
      await box.erase();

      Get.deleteAll(force: true);

      Get.offAllNamed(Routes.SIGNIN);
    } catch (e) {
      Get.snackbar(
        "Logout Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool canSave() {
    return nameController.text.trim().isNotEmpty &&
        bioController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty &&
        selectedGender.value.isNotEmpty &&
        selectedLookingFor.value.isNotEmpty &&
        selectedInterests.length >= 3 &&
        selectedProfileImage.value.isNotEmpty;
  }

  // ================= 🔥 UPDATED PATCH API =================
  Future<void> saveProfile() async {
    isSaving.value = true; // 🔥 START LOADER

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);

      if (token == null) throw "Token not found";

      final Map<String, dynamic> body = {};

      if (nameController.text.trim().isNotEmpty) {
        body["name"] = nameController.text.trim();
      }

      if (bioController.text.trim().isNotEmpty) {
        body["bio"] = bioController.text.trim();
      }

      if (locationController.text.trim().isNotEmpty) {
        body["locationName"] = locationController.text.trim();
      }

      if (selectedGender.value.isNotEmpty) {
        body["gender"] = selectedGender.value;
      }

      if (selectedAge.value > 0) {
        body["age"] = selectedAge.value.toInt();
      }

      if (selectedLookingFor.value.isNotEmpty) {
        body["lookingFor"] = selectedLookingFor.value;
      }

      if (selectedInterests.isNotEmpty) {
        body["interests"] = selectedInterests.toList();
      }

      if (selectedProfileImage.value.isNotEmpty) {
        body["profileImage"] = selectedProfileImage.value;
      }

      if (selectedGalleryImages.isNotEmpty) {
        body["gallery"] = selectedGalleryImages.toList();
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        body["location"] = {
          "lat": position.latitude,
          "lng": position.longitude,
        };
      } catch (e) {
        body["location"] = {"lat": 0.0, "lng": 0.0};
      }

      if (body.isEmpty) {
        Get.snackbar("No Changes", "Nothing to update");
        return;
      }

      await _userApi.updateProfile(token, body);

      Get.back();

      Get.snackbar(
        "Profile Updated",
        "Your profile has been updated successfully.",
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false; // 🔥 STOP LOADER
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 🔥 Customize as you want
        return "${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      }

      return "Unknown location";
    } catch (e) {
      return "Location not found";
    }
  }
}
