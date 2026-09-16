import 'package:get/get.dart';
import '../controller/agreement_record_controller.dart';

class AgreementRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgreementRecordController>(() => AgreementRecordController());
  }
}