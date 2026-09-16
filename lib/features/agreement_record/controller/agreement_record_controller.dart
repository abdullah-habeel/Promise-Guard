import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';

class AgreementRecordController extends GetxController {
  final RxList<AgreementItem> agreementItems = <AgreementItem>[].obs;
  final RxString resolutionStatus = 'pending'.obs;
  final RxString callName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value = args['callName'] as String? ?? 'Untitled Call';
      resolutionStatus.value = args['resolution'] as String? ?? 'pending';
      final items = args['agreementItems'];
      if (items != null && items is List<AgreementItem>) {
        agreementItems.assignAll(items);
      } else if (items != null && items is RxList<AgreementItem>) {
        agreementItems.assignAll(items);
      }
    }
  }

  void startNewCall() => Get.offAllNamed(AppRoutes.home);
}