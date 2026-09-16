import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 64,
                  color: Color(0xFF1B4F72),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PromiseGuard',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4F72),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Catch commitments before they become misunderstandings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Call name input
                TextField(
                  onChanged: (v) => controller.callName.value = v,
                  decoration: InputDecoration(
                    labelText: 'Call Name (optional)',
                    hintText: 'e.g. Acme GmbH — Enterprise License Call',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // File picker area
                Obx(() => GestureDetector(
                      onTap: controller.pickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.fileName.value.isEmpty
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF0E9E8E),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              controller.fileName.value.isEmpty
                                  ? Icons.upload_file_outlined
                                  : Icons.audio_file_outlined,
                              size: 40,
                              color: controller.fileName.value.isEmpty
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF0E9E8E),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.fileName.value.isEmpty
                                  ? 'Click to upload audio file'
                                  : controller.fileName.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: controller.fileName.value.isEmpty
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF0E9E8E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'MP3, WAV, M4A supported',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 24),

                // Analyze button
                Obx(() => FilledButton.icon(
                      onPressed: controller.fileName.value.isEmpty
                          ? null
                          : controller.startAnalysis,
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text(
                        'Analyze Call',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0E9E8E),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD1D5DB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}