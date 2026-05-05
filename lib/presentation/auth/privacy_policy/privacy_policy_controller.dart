import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/sources/local/local_storage.dart';
import '../../../core/routes/app_routes.dart';

class PrivacyPolicyController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onReady() {
    super.onReady();
    // Enable automatically if the screen is large enough that no scrolling is needed.
    if (scrollController.hasClients && scrollController.position.maxScrollExtent <= 0) {
      isButtonEnabled.value = true;
    }
  }

  void _onScroll() {
    if (!isButtonEnabled.value &&
        scrollController.position.pixels >=
            (scrollController.position.maxScrollExtent - 20)) {
      isButtonEnabled.value = true;
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void agreeAndContinue() {
    if (isButtonEnabled.value) {
      LocalStorage.setPrivacyPolicyAccepted(true);
      Get.offAllNamed(Routes.SIGNIN);
    }
  }
}
