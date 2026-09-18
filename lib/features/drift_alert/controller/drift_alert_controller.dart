import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import 'package:promise_guard/features/drift_alert/model/drift_evidence_model.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';
import '../service/drift_service.dart';

class DriftAlertController extends GetxController {
  final DriftService _service;

  DriftAlertController({DriftService? service})
      : _service = service ?? DriftService();

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool driftDetected = false.obs;
  final RxList<DriftEvidence> evidence = <DriftEvidence>[].obs;
  final RxString clarifyingQuestion = ''.obs;
  final RxString explanation = ''.obs;
  final RxString commercialTerm = ''.obs;
  final RxList<AgreementItem> agreementItems = <AgreementItem>[].obs;
  final RxString callName = ''.obs;
  final RxString transcriptId = ''.obs;

  // New traceability fields
  final RxString earlierEvidence = ''.obs;
  final RxString laterEvidence = ''.obs;
  final RxString stateChange = ''.obs;
  final RxString missingEvidence = ''.obs;

  static String pendingResolution = 'pending';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value = args['callName'] as String? ?? 'Untitled Call';
      final lines = args['transcriptLines'] as List<TranscriptLine>?;
      if (lines != null && lines.isNotEmpty) {
        _analyzeWithGemini(lines);
      } else {
        hasError.value = true;
        errorMessage.value = 'No transcript data found. Please go back and upload a call.';
        isLoading.value = false;
      }
    } else {
      hasError.value = true;
      errorMessage.value = 'No data received. Please go back and upload a call.';
      isLoading.value = false;
    }
  }

  Future<void> _analyzeWithGemini(List<TranscriptLine> lines) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final data = await _service.analyzeDrift(lines);

      driftDetected.value = data['driftDetected'] as bool? ?? false;
      clarifyingQuestion.value = data['clarifyingQuestion'] as String? ?? '';
      explanation.value = data['explanation'] as String? ?? '';
      commercialTerm.value = data['commercialTerm'] as String? ?? '';
      earlierEvidence.value = data['earlierEvidence'] as String? ?? '';
      laterEvidence.value = data['laterEvidence'] as String? ?? '';
      stateChange.value = data['stateChange'] as String? ?? '';
      missingEvidence.value = data['missingEvidence'] as String? ?? '';
      evidence.assignAll(_service.parseEvidence(data));

      final items = data['agreementItems'] as List<dynamic>? ?? [];
      agreementItems.assignAll(
        items.map((e) => AgreementItem.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Drift analysis failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void resolveDrift(bool confirmed) {
    pendingResolution = confirmed ? 'confirmed' : 'not_confirmed';
    Get.toNamed(
      AppRoutes.agreementRecord,
      arguments: {
        'callName': callName.value,
        'agreementItems': agreementItems,
        'resolution': pendingResolution,
      },
    );
  }

  void retry() => Get.offAllNamed(AppRoutes.home);
}