import 'package:flutter/material.dart';

class ExplanationCard extends StatelessWidget {
  final String explanation;

  const ExplanationCard({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF1B4F72), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why flagged',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}