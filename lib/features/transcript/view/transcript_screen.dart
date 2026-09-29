import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/theme/app_theme.dart';
import 'package:promise_guard/features/drift_alert/widgets/scafold.dart';
import 'package:promise_guard/features/transcript/widget/chat_bubble.dart';
import '../controller/transcript_controller.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TranscriptController>();

    return BackgroundScaffold(
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  scrolledUnderElevation: 0, // add this line
  systemOverlayStyle: const SystemUiOverlayStyle( // add this
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Divider(height: 1, color: Colors.white.withOpacity(0.15)), // softer divider
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20), // white
    onPressed: Get.back,
  ),
  title: Obx(() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'PromiseGuard',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white, // white
          letterSpacing: -0.3,
        ),
      ),
      if (controller.callName.value.isNotEmpty)
        Text(
          controller.callName.value,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withOpacity(0.65), // white muted
            fontWeight: FontWeight.w400,
          ),
        ),
    ],
  )),
),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(() {
                if (controller.entities.isEmpty) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppTheme.line)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: AppTheme.emerald, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'ASSEMBLYAI DETECTED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.muted,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: controller.entities.map((entity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Text(
                              entity.displayLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
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
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: FilledButton.icon(
              onPressed: controller.goToAnalysis,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Analyze Call', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}