import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';

class HomeController extends GetxController {
  final RxString callName = ''.obs;
  final RxString fileName = ''.obs;

  PlatformFile? pickedFile;

  bool get canAnalyze => pickedFile != null;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      pickedFile = result.files.first;
      fileName.value = pickedFile!.name;
    }
  }

  void startAnalysis() {
    Get.toNamed(
      AppRoutes.processing,
      arguments: {
        'file': pickedFile,
        'callName': callName.value.isEmpty
            ? 'Untitled Call'
            : callName.value,
      },
    );
  }
}