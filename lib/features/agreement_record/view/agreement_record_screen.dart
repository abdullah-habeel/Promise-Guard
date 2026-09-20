import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/agreement_record_controller.dart';

class AgreementRecordScreen extends StatelessWidget {
  const AgreementRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgreementRecordController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Agreement Record'),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final isConfirmed = controller.isConfirmed;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.verified_outlined, color: Color(0xFF1B4F72), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agreement Record',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4F72)),
                              ),
                              Text(
                                controller.callName.value,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Commercial Term + Status ──────────────────────────────
                  if (controller.commercialTerm.value.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Term
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label('COMMERCIAL TERM'),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  controller.commercialTerm.value,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 16),

                          // Status
                          Row(
                            children: [
                              const _Label('STATUS'),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isConfirmed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isConfirmed ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                                      size: 16,
                                      color: isConfirmed ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isConfirmed ? 'CONFIRMED' : '⚠ NEEDS CONFIRMATION',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isConfirmed ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Commitment path
                          if (controller.stateChange.value.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('COMMITMENT PATH'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    controller.stateChange.value,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Evidence range
                          if (controller.earlierEvidence.value.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const _Label('EVIDENCE'),
                                const SizedBox(width: 16),
                                _LineIdBadge(controller.earlierEvidence.value, color: const Color(0xFF1B4F72)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('→', style: TextStyle(color: Color(0xFF6B7280))),
                                ),
                                _LineIdBadge(controller.laterEvidence.value, color: const Color(0xFFDC2626)),
                              ],
                            ),
                          ],

                          // Missing confirmation
                          if (!isConfirmed && controller.missingEvidence.value.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('MISSING'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    controller.missingEvidence.value,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Clarifying question
                          if (!isConfirmed && controller.clarifyingQuestion.value.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Label('SUGGESTED\nQUESTION'),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '"${controller.clarifyingQuestion.value}"',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF4F46E5), fontStyle: FontStyle.italic, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ── Agreement Items Table ─────────────────────────────────
                  if (controller.agreementItems.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Text(
                              'Agreement Items',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4F72)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 2, child: _HeaderCell('ITEM')),
                                Expanded(flex: 2, child: _HeaderCell('VALUE')),
                                Expanded(flex: 2, child: _HeaderCell('EVIDENCE')),
                                Expanded(flex: 3, child: _HeaderCell('PARTICIPANTS')),
                              ],
                            ),
                          ),
                          ...controller.agreementItems.map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: Text(item.item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)))),
                                  Expanded(flex: 2, child: Text(item.value, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
                                  Expanded(flex: 2, child: Text(item.evidence, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
                                  Expanded(flex: 3, child: Text(item.participants, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // ── Start New Call ────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: controller.startNewCall,
                    icon: const Icon(Icons.phone_in_talk_outlined),
                    label: const Text('Start New Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4F72),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5),
      ),
    );
  }
}

class _LineIdBadge extends StatelessWidget {
  final String id;
  final Color color;
  const _LineIdBadge(this.id, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280), letterSpacing: 0.5));
  }
}