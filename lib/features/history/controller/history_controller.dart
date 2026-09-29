import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/call_record_model.dart';

class HistoryController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rx<CallRecordModel?> record = Rx(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final docId = args?['docId'] as String?;
    if (docId != null) _fetchCall(docId);
  }

  Future<void> _fetchCall(String docId) async {
    try {
      isLoading.value = true;
      final doc = await FirebaseFirestore.instance.collection('calls').doc(docId).get();
      if (doc.exists) {
        record.value = CallRecordModel.fromDoc(doc);
      } else {
        error.value = 'Call record not found.';
      }
    } catch (e) {
      error.value = 'Failed to load call.';
    } finally {
      isLoading.value = false;
    }
  }

  String get shareUrl => 'https://promiseguard.web.app/verify/${record.value?.docId ?? ''}';

  String formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}