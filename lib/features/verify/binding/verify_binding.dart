import 'package:get/get.dart';
import 'package:promise_guard/features/verify/controller/verify_controller.dart';

class VerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyController());
  }
}