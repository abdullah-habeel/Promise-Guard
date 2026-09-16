import 'package:flutter/material.dart';
import 'package:promise_guard/features/drift_alert/controller/drift_alert_controller.dart';

class ActionButtons extends StatelessWidget {
  final DriftAlertController controller;

  const ActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => controller.resolveDrift(true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'Confirmed',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.resolveDrift(false),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text(
              'Not Confirmed',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}