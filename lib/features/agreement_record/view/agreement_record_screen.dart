import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/theme/app_theme.dart';
import 'package:promise_guard/features/agreement_record/widgets/share_card.dart';
import 'package:promise_guard/features/drift_alert/widgets/scafold.dart';
import '../controller/agreement_record_controller.dart';
import 'package:collection/collection.dart';
class AgreementRecordScreen extends StatelessWidget {
  const AgreementRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgreementRecordController>();

    return BackgroundScaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        title: const Text(
          'Agreement Record',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
        ),
      ),
      body: Obx(() {
        final isConfirmed = controller.isConfirmed;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(controller: controller),
                  const SizedBox(height: 12),
                  const ShareCard(),
                  const SizedBox(height: 12),
                  if (controller.commercialTerm.value.isNotEmpty)
                    _DetailsCard(controller: controller, isConfirmed: isConfirmed),
                  const SizedBox(height: 12),
                  if (controller.agreementItems.isNotEmpty)
                    _AgreementItemsCard(controller: controller),
                  const SizedBox(height: 28),
                                   _ExportPdfButton(controller: controller),
                  const SizedBox(height: 12),
                  _StartNewCallButton(onTap: controller.startNewCall),
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

class _HeaderCard extends StatelessWidget {
  final AgreementRecordController controller;
  const _HeaderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecor(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_outlined, color: Color(0xFF1B4F72), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agreement Record',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                  controller.callName.value,
                  style: TextStyle(fontSize: 12.5, color: AppTheme.muted),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final AgreementRecordController controller;
  final bool isConfirmed;
  const _DetailsCard({required this.controller, required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        children: [
          _Row(
            label: 'COMMERCIAL TERM',
            child: Text(
              controller.commercialTerm.value,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppTheme.ink),
            ),
          ),
          _divider(),
          _Row(
            label: 'STATUS',
            child: _StatusBadge(isConfirmed: isConfirmed),
          ),
          if (controller.stateChange.value.isNotEmpty) ...[
            _divider(),
            _Row(
              label: 'COMMITMENT PATH',
              child: Text(
                controller.stateChange.value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB45309),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
          if (controller.earlierEvidence.value.isNotEmpty) ...[
            _divider(),
            _Row(
  label: 'EVIDENCE',
  child: Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _EvidenceBadge(id: controller.earlierEvidence.value, primary: true),
          const SizedBox(height: 3),
          Obx(() {
            final match = controller.commitmentTimeline.firstWhereOrNull(
              (e) => e.lineId == controller.earlierEvidence.value,
            );
            return Text(
              match?.timestamp ?? '',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.muted,
              ),
            );
          }),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.muted),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _EvidenceBadge(id: controller.laterEvidence.value, primary: false),
          const SizedBox(height: 3),
          Obx(() {
            final match = controller.commitmentTimeline.firstWhereOrNull(
              (e) => e.lineId == controller.laterEvidence.value,
            );
            return Text(
              match?.timestamp ?? '',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.muted,
              ),
            );
          }),
        ],
      ),
    ],
  ),
),
          ],
          if (!isConfirmed && controller.missingEvidence.value.isNotEmpty) ...[
            _divider(),
            _MissingEvidenceBlock(text: controller.missingEvidence.value),
          ],
          if (!isConfirmed && controller.clarifyingQuestion.value.isNotEmpty) ...[
            _divider(),
            _Row(
              label: 'SUGGESTED\nQUESTION',
              child: Text(
                '"${controller.clarifyingQuestion.value}"',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4F46E5),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFF3F4F6));
}

class _Row extends StatelessWidget {
  final String label;
  final Widget child;
  const _Row({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.muted,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MissingEvidenceBlock extends StatelessWidget {
  final String text;
  const _MissingEvidenceBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Missing Evidence',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF991B1B), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isConfirmed;
  const _StatusBadge({required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConfirmed ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: 14,
            color: isConfirmed ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 6),
          Text(
            isConfirmed ? 'CONFIRMED' : 'NEEDS CONFIRMATION',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isConfirmed ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceBadge extends StatelessWidget {
  final String id;
  final bool primary;
  const _EvidenceBadge({required this.id, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary ? const Color(0xFF1B4F72) : const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        id,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontFamily: 'monospace',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AgreementItemsCard extends StatelessWidget {
  final AgreementRecordController controller;
  const _AgreementItemsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                const Text(
                  'Agreement Items',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.agreementItems.length}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFF3F4F6))),
              color: Color(0xFFF9FAFB),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.item,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.value, style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(item.evidence, style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(item.participants, style: TextStyle(fontSize: 13, color: AppTheme.muted)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartNewCallButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartNewCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
      label: const Text('Start New Call', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppTheme.muted,
        letterSpacing: 0.6,
      ),
    );
  }
}
class _ExportPdfButton extends StatelessWidget {
  final AgreementRecordController controller;
  const _ExportPdfButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => OutlinedButton.icon(
      onPressed: controller.isExporting.value ? null : controller.exportPdf,
      icon: controller.isExporting.value
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf_rounded, size: 18),
      label: Text(
        controller.isExporting.value ? 'Exporting...' : 'Export PDF',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1B4F72),
        side: const BorderSide(color: Color(0xFF1B4F72), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ));
  }
}

BoxDecoration _cardDecor() => BoxDecoration(
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
);