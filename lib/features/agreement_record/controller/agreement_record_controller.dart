import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/core/service/firestore_service.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import 'package:promise_guard/features/agreement_record/model/commitment_timeline_model.dart';
import 'package:promise_guard/features/agreement_record/service/pdf_export_service.dart';

class AgreementRecordController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<AgreementItem> agreementItems = <AgreementItem>[].obs;
  final RxString resolutionStatus = 'pending'.obs;
  final RxString callName = ''.obs;
  final RxBool isSaving = false.obs;
  final RxBool saved = false.obs;
  final RxString shareDocId = ''.obs;
  final RxBool linkCopied = false.obs;
  final RxBool isExporting = false.obs;

  // Drift details
  final RxString commercialTerm = ''.obs;
  final RxString explanation = ''.obs;
  final RxString clarifyingQuestion = ''.obs;
  final RxString stateChange = ''.obs;
  final RxString earlierEvidence = ''.obs;
  final RxString laterEvidence = ''.obs;
  final RxString missingEvidence = ''.obs;
  final RxList<CommitmentTimelineEntry> commitmentTimeline =
      <CommitmentTimelineEntry>[].obs;
  bool _analyzedDriftDetected = false;

  bool get isConfirmed => resolutionStatus.value == 'confirmed';
  bool get needsConfirmation => resolutionStatus.value == 'not_confirmed';

  String get shareUrl => shareDocId.value.isEmpty
      ? ''
      : 'https://promiseguard.vercel.app/verify/${shareDocId.value}';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value           = args['callName']           as String? ?? 'Untitled Call';
      resolutionStatus.value   = args['resolution']         as String? ?? 'pending';
      commercialTerm.value     = args['commercialTerm']     as String? ?? '';
      explanation.value        = args['explanation']        as String? ?? '';
      clarifyingQuestion.value = args['clarifyingQuestion'] as String? ?? '';
      stateChange.value        = args['stateChange']        as String? ?? '';
      earlierEvidence.value    = args['earlierEvidence']    as String? ?? '';
      laterEvidence.value      = args['laterEvidence']      as String? ?? '';
      missingEvidence.value    = args['missingEvidence']    as String? ?? '';
      _analyzedDriftDetected   = args['driftDetected']      as bool? ?? false;

      final items = args['agreementItems'];
      if (items is List<AgreementItem>) {
        agreementItems.assignAll(items);
      } else if (items is RxList<AgreementItem>) {
        agreementItems.assignAll(items);
      }

      final timeline = args['commitmentTimeline'];
      if (timeline is List<CommitmentTimelineEntry>) {
        commitmentTimeline.assignAll(timeline);
      } else if (timeline is RxList<CommitmentTimelineEntry>) {
        commitmentTimeline.assignAll(timeline);
      }
    }
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      isSaving.value = true;
      final docId = await _firestoreService.saveCall(
        callName: callName.value,
        resolution: resolutionStatus.value,
        driftDetected: _analyzedDriftDetected,
        commercialTerm: commercialTerm.value,
        explanation: explanation.value,
        clarifyingQuestion: clarifyingQuestion.value,
        agreementItems: agreementItems,
      );
      shareDocId.value = docId;
      saved.value = true;
    } catch (e) {
      // Silent fail
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> copyShareLink() async {
    if (shareUrl.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: shareUrl));
    linkCopied.value = true;
    await Future.delayed(const Duration(seconds: 2));
    linkCopied.value = false;
  }

  Future<void> exportPdf() async {
    if (isExporting.value) return;
    try {
      isExporting.value = true;
      await PdfExportService().exportAgreementRecord(
        callName: callName.value,
        commercialTerm: commercialTerm.value,
        resolution: resolutionStatus.value,
        stateChange: stateChange.value,
        earlierEvidence: earlierEvidence.value,
        laterEvidence: laterEvidence.value,
        missingEvidence: missingEvidence.value,
        clarifyingQuestion: clarifyingQuestion.value,
        agreementItems: agreementItems,
      );
    } finally {
      isExporting.value = false;
    }
  }

  void startNewCall() => Get.offAllNamed(AppRoutes.home);
}