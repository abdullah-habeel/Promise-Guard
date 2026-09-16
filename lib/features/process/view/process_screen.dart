import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promise_guard/features/process/controller/process_controller.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Analyzing Call'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Obx(() {
              if (controller.hasError.value) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: controller.retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4F72),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 64,
                    color: Color(0xFF1B4F72),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PromiseGuard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  const SizedBox(height: 32),
                  LinearProgressIndicator(
                    value: controller.progress.value,
                    backgroundColor: const Color(0xFFD1D5DB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0E9E8E),
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.status.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(controller.progress.value * 100).toInt()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}