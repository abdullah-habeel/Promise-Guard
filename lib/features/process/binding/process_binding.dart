import 'package:get/get.dart';
import 'package:promise_guard/features/process/controller/process_controller.dart';

class ProcessingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessingController>(() => ProcessingController());
  }
}