import 'package:get/get.dart';
import 'package:promise_guard/features/history/controller/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HistoryController());
  }
}