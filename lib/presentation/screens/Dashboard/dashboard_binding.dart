import 'package:get/get.dart';
import 'package:zuno_application/presentation/screens/Dashboard/home/home_controller.dart';
import 'Chat/chat_controller.dart';
import 'activity/activity_controller.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ChatController>(() => ChatController());
    // Get.lazyPut<ActivityController>(() => ActivityController());
    Get.put(ActivityController());
  }
}
