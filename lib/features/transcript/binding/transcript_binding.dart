import 'package:get/get.dart';
import '../controller/transcript_controller.dart';
import '../service/transcript_service.dart';

class TranscriptBinding extends Bindings {
  @override
  void dependencies() {
    final service = TranscriptService();
    Get.put<TranscriptService>(service);
    Get.put<TranscriptController>(TranscriptController(service: service));
  }
}