import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Nearly/shared/constants/app_colors.dart';
import 'package:Nearly/shared/constants/app_text_styles.dart';
import 'package:Nearly/shared/widgets/common/app_refresh_wrapper.dart';
import 'package:Nearly/shared/widgets/common/Nearly_loader.dart';
import 'package:country_state_city/country_state_city.dart' hide State;

import 'package:Nearly/shared/widgets/common/nearly_image.dart';
import 'profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key}) {
    Future.microtask(() => Get.find<ProfileController>().prepareEditForm());
  }

  final ProfileController controller = Get.find<ProfileController>();

  // ─── Design tokens ────────────────────────────────────────────────────────
  static const _indigo = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isDark),
      body: Obx(
        () => Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: AppRefreshWrapper(
                    onRefresh: () async => controller.loadProfileData(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Upload your photos'),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Upload photos to show up in matches',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // New style Photo Grid (exactly 3 allowed)
                          _buildPinterestPhotoGrid(isDark),
                          const SizedBox(height: 16),

                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Photo Guide',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          _buildSectionTitle('Basics about me'),
                          _buildBasicsCard(context, isDark),

                          const SizedBox(height: 32),

                          _buildSectionTitle('About me'),
                          _buildAboutMeCard(context, isDark),

                          const SizedBox(height: 32),

                          _buildSectionTitle('Verification'),
                          _buildVerificationCard(context, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Save Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.95),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: _buildSaveButton(),
              ),
            ),

            NearlyLoader(isVisible: controller.isSaving.value),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      title: const Text(
        "Edit profile",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      titleSpacing: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          child: GestureDetector(
            onTap: () => controller.saveProfile(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B89FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'PREVIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFEEEEEE)),
      ),
    );
  }

  // ─── Photo Grid (3 slots total as requested) ─────────────────────────────────
  Widget _buildPinterestPhotoGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPhotoSlot(index: -1, isMain: true, height: 280),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPhotoSlot(index: 0, height: 160)),
              const SizedBox(width: 12),
              Expanded(child: _buildPhotoSlot(index: 1, height: 160)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot({
    required int index,
    bool isMain = false,
    required double height,
  }) {
    String imagePath = '';
    if (isMain) {
      imagePath = controller.selectedProfileImage.value;
    } else {
      if (index < controller.selectedGalleryImages.length) {
        imagePath = controller.selectedGalleryImages[index];
      }
    }

    final bool hasImage = imagePath.isNotEmpty;
    final int slotIndex = isMain ? -1 : index;

    Widget content = Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: hasImage
            ? null
            : Border.all(color: const Color(0xFFDDDDDD), width: 1.5),
      ),
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(imagePath),
              ),
            ),
          if (isMain && hasImage)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Main',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (!hasImage)
            const Center(
              child: Icon(Icons.add, color: Color(0xFFBBBBBB), size: 32),
            ),
          if (hasImage && !isMain)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => controller.removeGalleryImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    Widget draggableContent = hasImage
        ? LongPressDraggable<int>(
            data: slotIndex,
            feedback: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: 0.8,
                child: SizedBox(
                  width: 150,
                  height: height,
                  child: content,
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: content,
            ),
            child: content,
          )
        : content;

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        controller.swapImages(details.data, slotIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            if (!hasImage) {
              if (isMain) {
                controller.pickProfileImage();
              } else {
                controller.pickGalleryImage();
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: candidateData.isNotEmpty
                  ? Border.all(color: const Color(0xFF5B89FF), width: 3)
                  : null,
            ),
            child: draggableContent,
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _listCardContainer({required bool isDark, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: child,
    );
  }

  // ─── Cards ─────────────────────────────
  Widget _buildBasicsCard(BuildContext context, bool isDark) {
    return _listCardContainer(
      isDark: isDark,
      child: Column(
        children: [
          _buildListItem(
            icon: Icons.badge_outlined,
            label: controller.nameController.text.isNotEmpty
                ? controller.nameController.text
                : "Add Name",
            hideLabel: true,
            onTap: () => _showEditSheet(
              context,
              isDark,
              "Name",
              _buildTextFieldCard(
                isDark: isDark,
                controller: controller.nameController,
                hint: "Enter your name",
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.cake_outlined,
            label: controller.selectedAge.value > 0
                ? controller.selectedAge.value.round().toString()
                : "Add Age",
            hideLabel: true,
            onTap: () => _showEditSheet(
              context,
              isDark,
              "Age",
              _buildAgeSection(isDark),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.male_outlined,
            label: controller.selectedGender.value.isNotEmpty
                ? controller.selectedGender.value
                : "Add Gender",
            hideLabel: true,
            onTap: () => _navigateToListSelection(
              title: "Gender",
              items: controller.genderOptions
                  .map((e) => "${e['emoji']} ${e['label']}")
                  .toList(),
              currentValue: controller.selectedGender,
              onSelect: (val) {
                // val is like "👩 Woman", we just want "Woman"
                final realVal = val.toString().substring(2).trim();
                controller.selectGender(realVal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeCard(BuildContext context, bool isDark) {
    return _listCardContainer(
      isDark: isDark,
      child: Column(
        children: [
          _buildListItem(
            icon: Icons.circle_outlined,
            label: "My status",
            value: "Never married",
            showArrow: true,
            onTap: () {},
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.visibility_outlined,
            label: "Looking for",
            value: controller.selectedLookingFor.value.isNotEmpty
                ? controller.selectedLookingFor.value
                : "Marriage (immediate)",
            showArrow: true,
            onTap: () => _navigateToListSelection(
              title: "Looking for",
              items: controller.lookingForOptions
                  .map((e) => "${e['emoji']} ${e['title']}")
                  .toList(),
              currentValue: controller.selectedLookingFor,
              onSelect: (val) {
                final realVal = val.toString().substring(2).trim();
                controller.selectLookingFor(realVal);
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.spa_outlined,
            label: "Religion or faith",
            value: controller.selectedReligion.value.isNotEmpty
                ? controller.selectedReligion.value
                : "Add Religion",
            showArrow: true,
            onTap: () => _navigateToListSelection(
              title: "Religion or faith",
              items: controller.religionOptions,
              currentValue: controller.selectedReligion,
              onSelect: (val) {
                controller.selectedReligion.value = val;
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.location_on_outlined,
            label: "City",
            value: controller.locationController.text.isNotEmpty
                ? controller.locationController.text
                : "Delhi NCR",
            showArrow: true,
            onTap: () => _navigateToCitySelection(),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.edit_note_rounded,
            label: "Bio",
            value: controller.bioController.text.isNotEmpty
                ? controller.bioController.text
                : "Tap to edit",
            showArrow: true,
            onTap: () => _showEditSheet(
              context,
              isDark,
              "Bio",
              _buildTextFieldCard(
                isDark: isDark,
                controller: controller.bioController,
                hint: "Tell something about yourself",
                maxLines: 4,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.local_fire_department_outlined,
            label: "Interests",
            value: "${controller.selectedInterests.length} selected",
            showArrow: true,
            onTap: () => _navigateToListSelection(
              title: "Interests",
              items: controller.allInterests,
              currentValue: null,
              isMultiSelect: true,
              selectedItems: controller.selectedInterests,
              onSelect: (val) {
                controller.toggleInterest(val);
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.height,
            label: "Height",
            value: controller.selectedHeight.value.isNotEmpty
                ? controller.selectedHeight.value
                : "Add Height",
            showArrow: true,
            onTap: () => _navigateToListSelection(
              title: "Height",
              items: controller.heightOptions,
              currentValue: controller.selectedHeight,
              onSelect: (val) => controller.selectHeight(val),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.wb_sunny_outlined,
            label: "Zodiac sign",
            value: controller.selectedZodiac.value.isNotEmpty
                ? controller.selectedZodiac.value
                : "Add Zodiac",
            showArrow: true,
            onTap: () => _navigateToListSelection(
              title: "Zodiac sign",
              items: controller.zodiacOptions,
              currentValue: controller.selectedZodiac,
              onSelect: (val) => controller.selectZodiac(val),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.add_location_alt_outlined,
            label: "Relocation preference",
            showArrow: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, bool isDark) {
    return _listCardContainer(
      isDark: isDark,
      child: Column(
        children: [
          _buildListItem(
            icon: Icons.phone_android_outlined,
            label: "Mobile number",
            trailing: const Icon(
              Icons.check_circle,
              color: Color(0xFF4285F4),
              size: 22,
            ),
            onTap: () {},
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildListItem(
            icon: Icons.verified_outlined,
            label: "Photo verification (Get a blue tick)",
            showArrow: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String label,
    String? value,
    bool showArrow = false,
    Widget? trailing,
    bool hideLabel = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 16),
            if (!hideLabel)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (hideLabel)
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            if (!hideLabel) const Spacer(),
            if (value != null)
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            if (value != null && showArrow) const SizedBox(width: 12),
            if (showArrow)
              const Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // ─── Full Screen Navigations ────────────────────────────────────────────────

  void _navigateToCitySelection() {
    Get.to(() => CitySelectionScreen(controller: controller));
  }

  void _navigateToListSelection({
    required String title,
    required List<String> items,
    required RxString? currentValue,
    required Function(String) onSelect,
    bool isMultiSelect = false,
    RxList<String>? selectedItems,
  }) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                // Read values synchronously so Obx tracks them properly instead of inside the lazy itemBuilder!
                final currentSingleValue = currentValue?.value;
                final currentMultiList = isMultiSelect && selectedItems != null
                    ? selectedItems.toList()
                    : [];

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    bool isSelected = false;

                    if (isMultiSelect) {
                      isSelected = currentMultiList.contains(item);
                    } else {
                      // For single select, match the stripped text
                      final cleanedItem = item.startsWith(RegExp(r'^\S+\s'))
                          ? item.substring(2).trim()
                          : item;
                      isSelected = currentSingleValue == cleanedItem;
                    }

                    return InkWell(
                      onTap: () {
                        onSelect(item);
                        if (!isMultiSelect) {
                          Get.back();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Color(0xFF4285F4),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom sheet for remaining items (like Name/Age/Bio) ─────────────────────
  void _showEditSheet(
    BuildContext context,
    bool isDark,
    String title,
    Widget content,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.scaffoldDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit $title",
                style: AppTextStyles.headingMedium(
                  isDark: isDark,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              content,
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ─── Cleaned up Input Components (No Cards/Icons) ───────────────

  Widget _buildTextFieldCard({
    required bool isDark,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
        fontSize: 15,
        color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1A1A2E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall(
          isDark: isDark,
        ).copyWith(fontSize: 14),
        filled: true,
        fillColor: isDark ? AppColors.inputFillDark : const Color(0xFFF8F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _indigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildAgeSection(bool isDark) {
    return Obx(() {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your age',
                style: AppTextStyles.bodySmall(
                  isDark: isDark,
                ).copyWith(color: const Color(0xFF888888), fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _indigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${controller.selectedAge.value.round()} yrs',
                  style: const TextStyle(
                    color: _indigo,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _indigo,
              inactiveTrackColor: _indigo.withOpacity(0.15),
              thumbColor: _indigo,
              overlayColor: _indigo.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              trackHeight: 6,
            ),
            child: Slider(
              value: controller.selectedAge.value,
              min: 18,
              max: 80,
              divisions: 62,
              onChanged: controller.updateAge,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: controller.saveProfile,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: _indigo,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: _indigo.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Image helper ─────────────────────────────────────────────────────────
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith("http")) {
      return NearlyImage(imageUrl: imagePath, fit: BoxFit.cover);
    }
    if (imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }
    return Container(
      color: const Color(0xFFF3F2FD),
      child: const Center(child: Icon(Icons.person, size: 40)),
    );
  }
}

class CitySelectionScreen extends StatefulWidget {
  final ProfileController controller;
  const CitySelectionScreen({super.key, required this.controller});

  @override
  State<CitySelectionScreen> createState() => _CitySelectionScreenState();
}

class _CitySelectionScreenState extends State<CitySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allCitiesRaw = [];
  List<String> _filteredCities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchController.addListener(_filterCities);
  }

  Future<void> _loadCities() async {
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

      // Avoid duplicates and sort
      final uniqueCities = formattedCities.toSet().toList();
      uniqueCities.sort();

      if (mounted) {
        setState(() {
          _allCitiesRaw = uniqueCities;
          _filteredCities = uniqueCities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCitiesRaw;
      } else {
        _filteredCities = _allCitiesRaw
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Select city",
              style: TextStyle(
                fontSize: 28,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search city",
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4285F4)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const NearlyLoader(isVisible: true)
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredCities.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          widget.controller.locationController.text =
                              _filteredCities[index];
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Text(
                            _filteredCities[index],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
