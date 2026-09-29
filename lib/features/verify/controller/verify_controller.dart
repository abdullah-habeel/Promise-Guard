import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:promise_guard/features/history/model/call_record_model.dart';

class VerifyController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rx<CallRecordModel?> record = Rx(null);

  @override
  void onInit() {
    super.onInit();
    final docId = Get.parameters['docId'];
    if (docId != null && docId.isNotEmpty) {
      _fetchCall(docId);
    } else {
      error.value = 'Invalid verification link.';
      isLoading.value = false;
    }
  }

  Future<void> _fetchCall(String docId) async {
    try {
      isLoading.value = true;
      final doc = await FirebaseFirestore.instance.collection('calls').doc(docId).get();
      if (doc.exists) {
        record.value = CallRecordModel.fromDoc(doc);
      } else {
        error.value = 'This verification link is invalid or expired.';
      }
    } catch (e) {
      error.value = 'Failed to load record.';
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}