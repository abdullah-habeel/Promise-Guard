import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promise_guard/features/agreement_record/controller/agreement_record_controller.dart';

class ShareCard extends StatelessWidget {
  const ShareCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgreementRecordController>();

    return Obx(() {
      if (controller.isSaving.value || controller.shareUrl.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.link, color: Color(0xFF6C63FF), size: 18),
                SizedBox(width: 8),
                Text(
                  'Shareable Verification Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.shareUrl,
                style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.copyShareLink,
                icon: Icon(
                  controller.linkCopied.value ? Icons.check : Icons.copy,
                  size: 16,
                ),
                label: Text(
                  controller.linkCopied.value ? 'Copied!' : 'Copy Link',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.linkCopied.value
                      ? Colors.green
                      : const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}