import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/transcript/model/entity_model.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';
import '../service/transcript_service.dart';

class TranscriptController extends GetxController {
  final TranscriptService _service;

  TranscriptController({TranscriptService? service})
      : _service = service ?? TranscriptService();

  final RxList<TranscriptLine> transcriptLines = <TranscriptLine>[].obs;
  final RxList<DetectedEntity> entities = <DetectedEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString callName = ''.obs;
  final RxString transcriptId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value = args['callName'] as String? ?? 'Untitled Call';
      transcriptId.value = args['transcriptId'] as String? ?? '';

      final lines = args['transcriptLines'] as List<TranscriptLine>?;
      if (lines != null) transcriptLines.assignAll(lines);

      final ents = args['entities'] as List<DetectedEntity>?;
      if (ents != null) entities.assignAll(ents);
    }
  }

  void goToAnalysis() => Get.toNamed(
        AppRoutes.driftAlert,
        arguments: {
          'transcriptLines': transcriptLines,
          'callName': callName.value,
          'transcriptId': transcriptId.value,
        },
      );
}