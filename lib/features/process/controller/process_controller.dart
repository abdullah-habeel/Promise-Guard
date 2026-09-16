import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/transcript/service/transcript_service.dart';

class ProcessingController extends GetxController {
  final TranscriptService _service = TranscriptService();

  final RxString status = 'Uploading audio...'.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final file = args['file'] as PlatformFile?;
      final callName = args['callName'] as String? ?? 'Untitled Call';
      if (file != null && file.bytes != null) {
        _startProcessing(file, callName);
      } else {
        hasError.value = true;
        errorMessage.value = 'No file received. Please go back and upload a call.';
      }
    } else {
      hasError.value = true;
      errorMessage.value = 'No data received. Please go back and upload a call.';
    }
  }

  Future<void> _startProcessing(PlatformFile file, String callName) async {
    try {
      // Step 1 — Upload
      status.value = 'Uploading audio to AssemblyAI...';
      progress.value = 0.2;
      final transcriptId = await _service.uploadAudio(file.bytes!);

      // Step 2 — Poll
      status.value = 'Transcribing and detecting speakers...';
      progress.value = 0.5;
      final data = await _service.pollTranscript(transcriptId);

      // Step 3 — Parse
      status.value = 'Extracting commitment statements...';
      progress.value = 0.8;
      final lines = _service.parseUtterances(data);
      final entities = _service.parseEntities(data);

      // Step 4 — Navigate
      progress.value = 1.0;
      status.value = 'Done!';

      await Future.delayed(const Duration(milliseconds: 500));

      Get.offNamed(
        AppRoutes.transcript,
        arguments: {
          'transcriptLines': lines,
          'callName': callName,
          'transcriptId': transcriptId,
          'entities': entities,
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    }
  }

  void retry() {
    hasError.value = false;
    errorMessage.value = '';
    Get.offAllNamed(AppRoutes.home);
  }
}