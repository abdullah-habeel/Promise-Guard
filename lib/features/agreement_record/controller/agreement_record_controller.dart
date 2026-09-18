import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/core/service/firestore_service.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import 'package:promise_guard/features/drift_alert/controller/drift_alert_controller.dart';

class AgreementRecordController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<AgreementItem> agreementItems = <AgreementItem>[].obs;
  final RxString resolutionStatus = 'pending'.obs;
  final RxString callName = ''.obs;
  final RxBool isSaving = false.obs;
  final RxBool saved = false.obs;

  // From DriftAlertController
  String get _commercialTerm => DriftAlertController.pendingResolution;

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
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      isSaving.value = true;
      await _firestoreService.saveCall(
        callName: callName.value,
        resolution: resolutionStatus.value,
        driftDetected: true,
        commercialTerm: '',
        explanation: '',
        clarifyingQuestion: '',
        agreementItems: agreementItems,
      );
      saved.value = true;
    } catch (e) {
      // Silent fail — don't block the UI if Firestore save fails
    } finally {
      isSaving.value = false;
    }
  }

  void startNewCall() => Get.offAllNamed(AppRoutes.home);
}