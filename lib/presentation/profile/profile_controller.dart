import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Nearly/core/routes/app_routes.dart';
import 'package:Nearly/core/services/auth_service.dart';
import 'package:Nearly/presentation/home/home_controller.dart';
import 'package:Nearly/data/sources/remote/user_api.dart'; // ✅ ADD

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
  final RxString selectedReligion = ''.obs; // ✅ ADD
  final RxList<String> selectedInterests = <String>[].obs;

  final RxString selectedProfileImage = ''.obs;
  final RxList<String> selectedGalleryImages = <String>[].obs;

  // Track public IDs for remote images
  final Map<String, String> _urlToPublicId = {};
  // Track images to be deleted on save
  final List<String> _photosToDelete = [];

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

  final List<String> religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Buddhist',
    'Parsi',
    'Sikh',
    'Jain',
    'Atheist',
    'Other',
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
      print("📄 FULL PROFILE RESPONSE: ${jsonEncode(data)}");

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

      // Handle images and find primary
      final List<dynamic> galleryData = data["images"] ?? [];
      final List<String> galleryUrls = [];
      String profileUrl = "";

      for (var item in galleryData) {
        if (item is Map) {
          final url = item["url"] ?? "";
          final bool isPrimary = item["isPrimary"] ?? false;
          final String? publicId = item["publicId"];

          if (publicId != null) {
            _urlToPublicId[url] = publicId;
          }

          if (isPrimary) {
            profileUrl = url;
          } else {
            galleryUrls.add(url);
          }
        }
      }

      // If no image was marked primary, use the first one if available
      if (profileUrl.isEmpty && galleryUrls.isNotEmpty) {
        profileUrl = galleryUrls.removeAt(0);
      }

      profile.value = DatingProfile(
        id: data["userId"] ?? "",
        userName: data["name"] ?? "",
        age: (data["age"] ?? "").toString(),
        bio: data["bio"] ?? "",
        location: locationName,
        interests: List<String>.from(data["interests"] ?? []),
        profileImageUrl: profileUrl,
        isActiveNow: true,
        distance: "",
        imageUrls: galleryUrls,
        gender: data["gender"],
        lookingFor: data["lookingFor"],
        religion: data["religion"],
      );

      nameController.text = data["name"] ?? "";
      bioController.text = data["bio"] ?? "";
      locationController.text = locationName;

      selectedGender.value = data["gender"] ?? "";
      selectedAge.value = (data["age"] ?? 24).toDouble();
      selectedLookingFor.value = data["lookingFor"] ?? "";
      selectedReligion.value = data["religion"] ?? "";

      selectedInterests.assignAll(List<String>.from(data["interests"] ?? []));
      selectedGalleryImages.assignAll(galleryUrls);
      selectedProfileImage.value = profileUrl;

      _photosToDelete.clear(); // Reset deletions
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Pre-fill all edit form fields from current profile state
  void prepareEditForm() {
    final p = profile.value;
    if (p == null) return;

    nameController.text = p.userName;
    bioController.text = p.bio;
    locationController.text = p.location;

    selectedGender.value = p.gender ?? "";
    selectedAge.value = double.tryParse(p.age) ?? 24.0;
    selectedLookingFor.value = p.lookingFor ?? "";
    selectedReligion.value = p.religion ?? "";

    selectedInterests.assignAll(p.interests);
    selectedGalleryImages.assignAll(p.imageUrls);
    selectedProfileImage.value = p.profileImageUrl;
  }
  // ================= IMAGE ACTIONS =================

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final oldUrl = selectedProfileImage.value;
      if (oldUrl.startsWith('http') && _urlToPublicId.containsKey(oldUrl)) {
        _photosToDelete.add(_urlToPublicId[oldUrl]!);
      }
      selectedProfileImage.value = image.path;
    }
  }

  Future<void> pickGalleryImage() async {
    if (selectedGalleryImages.length >= 2) {
      Get.snackbar(
        "Limit Reached",
        "You can upload maximum 2 gallery photos.",
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

    final removedUrl = selectedGalleryImages[index];
    // If it's a remote image, track it for deletion
    if (removedUrl.startsWith('http') &&
        _urlToPublicId.containsKey(removedUrl)) {
      _photosToDelete.add(_urlToPublicId[removedUrl]!);
    }

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

  void swapImages(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    String fromPath = fromIndex == -1 
        ? selectedProfileImage.value 
        : (fromIndex < selectedGalleryImages.length ? selectedGalleryImages[fromIndex] : '');
    
    if (fromPath.isEmpty) return; // Cannot drag an empty slot

    String toPath = toIndex == -1 
        ? selectedProfileImage.value 
        : (toIndex < selectedGalleryImages.length ? selectedGalleryImages[toIndex] : '');

    List<String> newGallery = List.from(selectedGalleryImages);

    // Update fromIndex slot
    if (fromIndex == -1) {
      selectedProfileImage.value = toPath;
    } else {
      if (fromIndex < newGallery.length) {
        newGallery[fromIndex] = toPath;
      }
    }

    // Update toIndex slot
    if (toIndex == -1) {
      selectedProfileImage.value = fromPath;
    } else {
      if (toIndex < newGallery.length) {
        newGallery[toIndex] = fromPath;
      } else {
        while (newGallery.length < toIndex) {
          newGallery.add('');
        }
        newGallery.add(fromPath);
      }
    }

    newGallery.removeWhere((item) => item.isEmpty);
    selectedGalleryImages.assignAll(newGallery);
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
    isSaving.value = true;

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);

      if (token == null) throw "Token not found";

      // 1. Handle Deletions
      for (var publicId in _photosToDelete) {
        try {
          await _userApi.deletePhoto(token, publicId);
        } catch (e) {
          print("Failed to delete photo $publicId: $e");
        }
      }
      _photosToDelete.clear();

      // 2. Handle Profile Image Upload
      if (selectedProfileImage.value.isNotEmpty &&
          !selectedProfileImage.value.startsWith('http')) {
        final result = await _userApi.uploadPhoto(
          token,
          selectedProfileImage.value,
        );
        final publicId = result['data']?['publicId'];
        if (publicId != null) {
          await _userApi.setPrimaryPhoto(token, publicId);
        }
      }

      // 3. Handle Gallery Uploads
      for (var imgPath in selectedGalleryImages) {
        if (!imgPath.startsWith('http')) {
          await _userApi.uploadPhoto(token, imgPath);
        }
      }

      // 4. Update Other Profile Data
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
      if (selectedReligion.value.isNotEmpty) {
        body["religion"] = selectedReligion.value;
      }
      if (selectedInterests.isNotEmpty) {
        body["interests"] = selectedInterests.toList();
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

      if (body.isNotEmpty) {
        await _userApi.updateProfile(token, body);
      }

      await loadProfileData(); // Refresh data
      Get.back();
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false;
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
