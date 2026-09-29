import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/theme/app_theme.dart';
import 'package:promise_guard/features/drift_alert/widgets/scafold.dart';
import '../controller/history_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
          onPressed: Get.back,
        ),
        title: const Text(
          'Call Detail',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(controller.error.value,
                style: const TextStyle(color: Colors.red, fontSize: 14)),
          );
        }
        final r = controller.record.value!;
        final isConfirmed = r.resolution == 'confirmed';

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _card(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.history_rounded, color: Color(0xFF1B4F72), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.callName,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                              const SizedBox(height: 2),
                              Text(controller.formatDate(r.timestamp),
                                  style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Share link
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.link, color: Color(0xFF6C63FF), size: 16),
                            SizedBox(width: 6),
                            Text('Verification Link',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            controller.shareUrl,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280), fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: controller.shareUrl));
                              Get.snackbar('Copied', 'Link copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2));
                            },
                            icon: const Icon(Icons.copy, size: 15),
                            label: const Text('Copy Link'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              side: const BorderSide(color: Color(0xFF6C63FF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details
                  _card(
                    child: Column(
                      children: [
                        _row('COMMERCIAL TERM',
                            Text(r.commercialTerm.isEmpty ? '—' : r.commercialTerm,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.ink))),
                        _divider(),
                        _row(
                          'STATUS',
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isConfirmed
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isConfirmed
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isConfirmed
                                      ? Icons.check_circle_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 13,
                                  color: isConfirmed
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isConfirmed ? 'CONFIRMED' : 'NEEDS CONFIRMATION',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isConfirmed
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (r.explanation.isNotEmpty) ...[
                          _divider(),
                          _row('EXPLANATION',
                              Text(r.explanation,
                                  style: TextStyle(
                                      fontSize: 13, color: AppTheme.muted, height: 1.5))),
                        ],
                        if (r.clarifyingQuestion.isNotEmpty) ...[
                          _divider(),
                          _row('SUGGESTED QUESTION',
                              Text('"${r.clarifyingQuestion}"',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF4F46E5),
                                      fontStyle: FontStyle.italic,
                                      height: 1.5))),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );

  Widget _row(String label, Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                      letterSpacing: 0.6)),
            ),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      );

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF3F4F6));
}