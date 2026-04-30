import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_state_city/country_state_city.dart' hide State;
import 'package:geolocator/geolocator.dart';
import 'package:Nearly/data/sources/local/local_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/sources/remote/user_api.dart';
import '../../../shared/utils/app_notifications.dart';

class OnboardingController extends GetxController {
  // ================= STATE =================

  final RxInt _currentStep = 0.obs;
  int get currentStep => _currentStep.value;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController citySearchController = TextEditingController();

  final RxString _selectedGender = ''.obs;
  String get selectedGender => _selectedGender.value;

  final RxDouble _selectedAge = 24.0.obs;
  double get selectedAge => _selectedAge.value;

  final RxString _lookingFor = ''.obs;
  String get lookingFor => _lookingFor.value;

  final RxString _selectedReligion = ''.obs;
  String get selectedReligion => _selectedReligion.value;

  final RxString _selectedHeight = ''.obs;
  String get selectedHeight => _selectedHeight.value;

  final RxString _selectedZodiac = ''.obs;
  String get selectedZodiac => _selectedZodiac.value;

  final RxString _selectedCity = ''.obs;
  String get selectedCity => _selectedCity.value;

  final RxList<String> selectedInterests = <String>[].obs;

  final RxString _selectedProfileImage = ''.obs;
  String get selectedProfileImage => _selectedProfileImage.value;

  final RxList<String> selectedGalleryImages = <String>[].obs;

  final RxList<String> allCitiesRaw = <String>[].obs;
  final RxList<String> filteredCities = <String>[].obs;
  final RxBool isLoadingCities = true.obs;
  final RxBool isLoading = false.obs;

  /// Used only for name/bio field button refresh
  final RxString _nameValue = ''.obs;
  String get nameValue => _nameValue.value;
  final RxString _bioValue = ''.obs;
  String get bioValue => _bioValue.value;

  final AuthService _authService = AuthService();
  final UserApi _userApi = UserApi();
  final ImagePicker _picker = ImagePicker();

  // ================= DATA =================

  final List<Map<String, String>> introSlides = [
    {
      'emoji': '💫',
      'title': 'Find People Nearby 📍',
      'description':
          'Discover amazing people around you. Connect with those who share your vibe and interests.',
    },
    {
      'emoji': '✨',
      'title': 'Real Connections Only 💜',
      'description':
          'Match with people who truly align with your personality and lifestyle.',
    },
    {
      'emoji': '⚡',
      'title': 'Start Your Journey',
      'description': 'Create your profile and begin finding your spark today.',
    },
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

  final List<String> interests = [
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

  final List<String> zodiacOptions = [
    '♈ Aries',
    '♉ Taurus',
    '♊ Gemini',
    '♋ Cancer',
    '♌ Leo',
    '♍ Virgo',
    '♎ Libra',
    '♏ Scorpio',
    '♐ Sagittarius',
    '♑ Capricorn',
    '♒ Aquarius',
    '♓ Pisces',
  ];

  final List<String> heightOptions = List.generate(
    81,
    (index) => "${140 + index} cm",
  );

  // ================= ACTIONS =================

  @override
  void onInit() {
    super.onInit();
    nameController.text = LocalStorage.name ?? '';
    _nameValue.value = nameController.text;

    citySearchController.addListener(() {
      filterCities(citySearchController.text);
    });
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      final cities = await getCountryCities('IN');
      final states = await getStatesOfCountry('IN');
      final stateCodeToName = <String, String>{};
      for (var state in states) {
        stateCodeToName[state.isoCode] = state.name;
      }
      final formattedCities = cities.map((c) {
        final stateName = stateCodeToName[c.stateCode] ?? c.stateCode;
        return "${c.name}, $stateName";
      }).toList();
      final uniqueCities = formattedCities.toSet().toList();
      uniqueCities.sort();
      allCitiesRaw.assignAll(uniqueCities);
      filteredCities.assignAll(uniqueCities);
      isLoadingCities.value = false;
    } catch (e) {
      isLoadingCities.value = false;
    }
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      filteredCities.assignAll(allCitiesRaw);
    } else {
      filteredCities.assignAll(
        allCitiesRaw
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  void nextStep() {
    if (!canContinue()) return;
    if (_currentStep.value < 13) {
      _currentStep.value++;
    } else {
      submitProfile();
    }
  }

  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }

  void skipIntro() {
    _currentStep.value = 3;
  }

  void selectGender(String value) {
    if (_selectedGender.value == value) return;
    _selectedGender.value = value;
  }

  void updateAge(double value) {
    final newValue = value.clamp(18.0, 80.0);
    if (_selectedAge.value == newValue) return;
    _selectedAge.value = newValue;
  }

  void selectLookingFor(String value) {
    if (_lookingFor.value == value) return;
    _lookingFor.value = value;
  }

  void selectReligion(String value) {
    if (_selectedReligion.value == value) return;
    _selectedReligion.value = value;
  }

  void selectHeight(String value) {
    if (_selectedHeight.value == value) return;
    _selectedHeight.value = value;
  }

  void selectZodiac(String value) {
    if (_selectedZodiac.value == value) return;
    _selectedZodiac.value = value;
  }

  void selectCity(String value) {
    if (_selectedCity.value == value) return;
    _selectedCity.value = value;
  }

  void toggleInterest(String value) {
    if (selectedInterests.contains(value)) {
      selectedInterests.remove(value);
    } else {
      selectedInterests.add(value);
    }
  }

  void onNameChanged(String value) {
    if (_nameValue.value == value.trim()) return;
    _nameValue.value = value.trim();
  }

  void onBioChanged(String value) {
    if (_bioValue.value == value.trim()) return;
    _bioValue.value = value.trim();
  }

  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) _selectedProfileImage.value = image.path;
  }

  Future<void> pickGalleryImage() async {
    if (selectedGalleryImages.length >= 2) {
      AppNotifications.showError("You can upload maximum 2 gallery photos.");
      return;
    }
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) selectedGalleryImages.add(image.path);
  }

  void removeGalleryImage(int index) {
    selectedGalleryImages.removeAt(index);
  }

  void swapImages(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;

    String fromPath = fromIndex == -1 
        ? _selectedProfileImage.value 
        : (fromIndex < selectedGalleryImages.length ? selectedGalleryImages[fromIndex] : '');
    
    if (fromPath.isEmpty) return; // Cannot drag an empty slot

    String toPath = toIndex == -1 
        ? _selectedProfileImage.value 
        : (toIndex < selectedGalleryImages.length ? selectedGalleryImages[toIndex] : '');

    List<String> newGallery = List.from(selectedGalleryImages);

    // Update fromIndex slot
    if (fromIndex == -1) {
      _selectedProfileImage.value = toPath;
    } else {
      if (fromIndex < newGallery.length) {
        newGallery[fromIndex] = toPath;
      }
    }

    // Update toIndex slot
    if (toIndex == -1) {
      _selectedProfileImage.value = fromPath;
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

  Future<void> submitProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      double lat = 0.0;
      double lng = 0.0;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (e) {
        // Location capture failed silently or handle as needed
      }

      final body = {
        "name": nameController.text.trim(),
        "gender": selectedGender,
        "age": selectedAge.toInt(),
        "bio": bioController.text.trim().isEmpty
            ? "Hello"
            : bioController.text.trim(),
        "interests": selectedInterests.toList(),
        "lookingFor": lookingFor,
        "religion": selectedReligion,
        "height": selectedHeight,
        "zodiac": selectedZodiac,
        "location": {"city": selectedCity, "lat": lat, "lng": lng},
      };

      await _userApi.createProfile(token, body);

      // 1. Upload Main Photo
      if (selectedProfileImage.isNotEmpty) {
        final result = await _userApi.uploadPhoto(token, selectedProfileImage);
        final publicId = result['data']?['publicId'];

        if (publicId != null) {
          await _userApi.setPrimaryPhoto(token, publicId);
        }
      }

      for (int i = 0; i < selectedGalleryImages.length; i++) {
        final imgPath = selectedGalleryImages[i];
        await _userApi.uploadPhoto(token, imgPath);
      }
      Get.offAllNamed("/dashboard");
    } catch (e) {
      AppNotifications.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool canContinue() {
    switch (currentStep) {
      case 0:
      case 1:
      case 2:
        return true;
      case 3:
        return nameValue.trim().isNotEmpty;
      case 4:
        return bioValue.trim().isNotEmpty;
      case 5:
        return selectedGender.isNotEmpty;
      case 6:
        return true; // Age has slider
      case 7:
        return lookingFor.isNotEmpty;
      case 8:
        return selectedInterests.length >= 3;
      case 9:
        return selectedReligion.isNotEmpty;
      case 10:
        return selectedHeight.isNotEmpty;
      case 11:
        return selectedZodiac.isNotEmpty;
      case 12:
        return selectedCity.isNotEmpty;
      case 13:
        return selectedProfileImage.isNotEmpty; // must have at least main image
      default:
        return false;
    }
  }

  String getButtonText() {
    return currentStep == 13 ? 'Continue →' : 'Next →';
  }
}
