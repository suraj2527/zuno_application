import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // ================= STATE =================

  final RxInt _currentStep = 0.obs;
  int get currentStep => _currentStep.value;

  final TextEditingController nameController = TextEditingController();

  final RxString _selectedGender = ''.obs;
  String get selectedGender => _selectedGender.value;

  final RxDouble _selectedAge = 24.0.obs;
  double get selectedAge => _selectedAge.value;

  final RxString _lookingFor = ''.obs;
  String get lookingFor => _lookingFor.value;

  final RxList<String> selectedInterests = <String>[].obs;

  /// Used only for name field button refresh
  final RxString _nameValue = ''.obs;
  String get nameValue => _nameValue.value;

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
      'description':
          'Create your profile and begin finding your spark today.',
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

  // ================= ACTIONS =================

  void nextStep() {
    if (!canContinue()) return;

    if (_currentStep.value < 7) {
      _currentStep.value++;
    } else {
      Get.offAllNamed("/dashboard");
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

  // ================= HELPERS =================

  bool canContinue() {
    switch (currentStep) {
      case 0:
      case 1:
      case 2:
        return true;
      case 3:
        return nameValue.trim().isNotEmpty;
      case 4:
        return selectedGender.isNotEmpty;
      case 5:
        return true;
      case 6:
        return lookingFor.isNotEmpty;
      case 7:
        return selectedInterests.length >= 3;
      default:
        return false;
    }
  }

  String getButtonText() {
    return currentStep == 7 ? 'Continue →' : 'Next →';
  }

  @override
  void onClose() {
    super.onClose();
  }
}