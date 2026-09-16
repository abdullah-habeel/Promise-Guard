import 'package:get/get.dart';
import '../controller/drift_alert_controller.dart';
import '../service/drift_service.dart';

class DriftAlertBinding extends Bindings {
  @override
  void dependencies() {
    final service = DriftService();
    Get.put<DriftService>(service);
    Get.put<DriftAlertController>(DriftAlertController(service: service));
  }
}