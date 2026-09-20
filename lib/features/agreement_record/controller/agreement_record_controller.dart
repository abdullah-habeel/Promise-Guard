import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/core/service/firestore_service.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';

class AgreementRecordController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<AgreementItem> agreementItems = <AgreementItem>[].obs;
  final RxString resolutionStatus = 'pending'.obs;
  final RxString callName = ''.obs;
  final RxBool isSaving = false.obs;
  final RxBool saved = false.obs;

  // Drift details
  final RxString commercialTerm = ''.obs;
  final RxString explanation = ''.obs;
  final RxString clarifyingQuestion = ''.obs;
  final RxString stateChange = ''.obs;
  final RxString earlierEvidence = ''.obs;
  final RxString laterEvidence = ''.obs;
  final RxString missingEvidence = ''.obs;

  bool get isConfirmed => resolutionStatus.value == 'confirmed';
  bool get needsConfirmation => resolutionStatus.value == 'not_confirmed';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value        = args['callName']        as String? ?? 'Untitled Call';
      resolutionStatus.value = args['resolution']     as String? ?? 'pending';
      commercialTerm.value  = args['commercialTerm']  as String? ?? '';
      explanation.value     = args['explanation']     as String? ?? '';
      clarifyingQuestion.value = args['clarifyingQuestion'] as String? ?? '';
      stateChange.value     = args['stateChange']     as String? ?? '';
      earlierEvidence.value = args['earlierEvidence'] as String? ?? '';
      laterEvidence.value   = args['laterEvidence']   as String? ?? '';
      missingEvidence.value = args['missingEvidence'] as String? ?? '';
      print('DEBUG commercialTerm: ${commercialTerm.value}');
      print('DEBUG stateChange: ${stateChange.value}');
      print('DEBUG missingEvidence: ${missingEvidence.value}');
      final items = args['agreementItems'];
      if (items is List<AgreementItem>) {
        agreementItems.assignAll(items);
      } else if (items is RxList<AgreementItem>) {
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
        commercialTerm: commercialTerm.value,
        explanation: explanation.value,
        clarifyingQuestion: clarifyingQuestion.value,
        agreementItems: agreementItems,
      );
      saved.value = true;
    } catch (e) {
      // Silent fail
    } finally {
      isSaving.value = false;
    }
  }

  void startNewCall() => Get.offAllNamed(AppRoutes.home);
}