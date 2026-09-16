import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promise_guard/features/transcript/widget/chat_bubble.dart';
import '../controller/transcript_controller.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TranscriptController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PromiseGuard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.callName.value,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            )),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Entity detection banner
              Obx(() {
                if (controller.entities.isEmpty) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: const Color(0xFFEFF6FF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Color(0xFF1B4F72),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'AssemblyAI Detected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4F72),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: controller.entities.map((entity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1B4F72).withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              entity.displayLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1B4F72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),

              // Transcript list
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: controller.transcriptLines.length,
                    itemBuilder: (context, index) =>
                        ChatBubble(line: controller.transcriptLines[index]),
                  ),
                ),
              ),
            ],
          ),

          // Analyze button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: FilledButton.icon(
              onPressed: controller.goToAnalysis,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text(
                'Analyze Call',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}