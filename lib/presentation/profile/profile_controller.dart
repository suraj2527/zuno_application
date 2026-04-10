import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zuno_application/presentation/home/home_controller.dart';

class ProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final ImagePicker _picker = ImagePicker();

  // ================= PROFILE STATE =================

  final Rxn<DatingProfile> profile = Rxn<DatingProfile>();
  final RxBool isLoading = false.obs;

  /// for gallery slider indicator
  final RxInt currentGalleryIndex = 0.obs;

  // ================= EDIT FORM CONTROLLERS =================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxDouble selectedAge = 24.0.obs;
  final RxString selectedLookingFor = ''.obs;
  final RxList<String> selectedInterests = <String>[].obs;

  /// ✅ main profile image (single)
  final RxString selectedProfileImage = ''.obs;

  /// ✅ gallery images only (max 3)
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
    {
      'emoji': '☕',
      'title': 'Casual Dating',
      'subtitle': 'Go with the flow',
    },
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

  DatingProfile? get myProfile =>
      homeController.allProfiles.isNotEmpty ? homeController.allProfiles.first : null;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    isLoading.value = true;

    final data = myProfile;
    if (data == null) {
      isLoading.value = false;
      return;
    }

    profile.value = data;

    // form values
    nameController.text = data.userName;
    bioController.text = data.bio;
    locationController.text = data.location;
    selectedGender.value = data.gender ?? '';
    selectedAge.value = double.tryParse(data.age) ?? 24.0;
    selectedLookingFor.value = data.lookingFor ?? '';
    selectedInterests.assignAll(data.interests);

    /// separate image states
    selectedProfileImage.value = data.profileImageUrl;
    selectedGalleryImages.assignAll(data.imageUrls);

    currentGalleryIndex.value = 0;

    isLoading.value = false;
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

  bool canSave() {
    return nameController.text.trim().isNotEmpty &&
        bioController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty &&
        selectedGender.value.isNotEmpty &&
        selectedLookingFor.value.isNotEmpty &&
        selectedInterests.length >= 3 &&
        selectedProfileImage.value.isNotEmpty;
  }

  void saveProfile() {
    if (!canSave()) {
      Get.snackbar(
        "Incomplete Profile",
        "Please complete all required details.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final existing = myProfile;
    if (existing == null) return;

    final updatedProfile = existing.copyWith(
      userName: nameController.text.trim(),
      age: selectedAge.value.round().toString(),
      bio: bioController.text.trim(),
      location: locationController.text.trim(),
      interests: selectedInterests.toList(),
      profileImageUrl: selectedProfileImage.value,
      imageUrls: selectedGalleryImages.toList(),
      gender: selectedGender.value,
      lookingFor: selectedLookingFor.value,
    );

    homeController.allProfiles[0] = updatedProfile;
    profile.value = updatedProfile;

    Get.back();

    Get.snackbar(
      "Profile Updated",
      "Your profile has been updated successfully.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.onClose();
  }
}