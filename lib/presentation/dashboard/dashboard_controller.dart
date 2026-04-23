import 'package:get/get.dart';
import 'package:zuno_application/presentation/activity/activity_controller.dart';

class DashboardController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 2 && Get.isRegistered<ActivityController>()) {
      Get.find<ActivityController>().markUpdatesAsSeen();
    }
  }
}