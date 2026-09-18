import 'package:flutter/material.dart';
import 'package:promise_guard/core/config/commitment_state.dart';
import 'package:promise_guard/features/drift_alert/model/drift_evidence_model.dart';
import '../../../../core/theme/app_theme.dart';

class EvidenceCard extends StatelessWidget {
  final DriftEvidence evidence;

  const EvidenceCard({super.key, required this.evidence});

  Color get _chipColor {
    return switch (evidence.state) {
      CommitmentState.tentative         => AppTheme.tentative,
      CommitmentState.confirmed         => AppTheme.committed,
      _                                 => AppTheme.pending,
    };
  }

  bool get _isEarlier =>
      evidence.state == CommitmentState.tentative ||
      evidence.state == CommitmentState.possibility;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_isEarlier ? "Earlier" : "Later"} (${evidence.timestamp})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '"${evidence.quote}"',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF1A1A2E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _chipColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _chipColor),
              ),
              child: Text(
                evidence.stateLabelDisplay,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _chipColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}