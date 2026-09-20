import 'package:get/get.dart';
import '../controller/live_call_controller.dart';

class LiveCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LiveCallController());
  }
}