import 'package:flutter/material.dart';
import 'package:promise_guard/features/drift_alert/model/drift_evidence_model.dart';

class DriftWarningCard extends StatelessWidget {
  final DriftEvidence committedEvidence;

  const DriftWarningCard({super.key, required this.committedEvidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFE65100), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE65100),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ PROMISE DRIFT DETECTED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBF360C),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  committedEvidence.commercialTerm,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}