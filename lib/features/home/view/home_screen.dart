import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promise_guard/core/service/firestore_service.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final firestoreService = FirestoreService();

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
                Obx(
                  () => GestureDetector(
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
                  ),
                ),
                const SizedBox(height: 24),

                // Analyze button
                Obx(
                  () => FilledButton.icon(
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
                  ),
                ),
                const SizedBox(height: 48),

                // Past Calls section
                const Row(
                  children: [
                    Icon(Icons.history, size: 18, color: Color(0xFF1B4F72)),
                    SizedBox(width: 8),
                    Text(
                      'Past Calls',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F72),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getPastCalls(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0E9E8E),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Text(
                          'No past calls yet. Analyze your first call above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs.toList();
                    docs.sort((a, b) {
                      final aTime =
                          (a['timestamp'] as Timestamp?)
                              ?.millisecondsSinceEpoch ??
                          0;
                      final bTime =
                          (b['timestamp'] as Timestamp?)
                              ?.millisecondsSinceEpoch ??
                          0;
                      return bTime.compareTo(aTime);
                    });

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final callName =
                            data['callName'] as String? ?? 'Untitled Call';
                        final resolution =
                            data['resolution'] as String? ?? 'pending';
                        final driftDetected =
                            data['driftDetected'] as bool? ?? false;
                        final timestamp = data['timestamp'] as Timestamp?;
                        final date = timestamp != null
                            ? _formatDate(timestamp.toDate())
                            : 'Just now';

                        final isConfirmed = resolution == 'confirmed';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: driftDetected
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  driftDetected
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                                  color: driftDetected
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF16A34A),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      callName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isConfirmed
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isConfirmed ? 'Confirmed' : 'Not Confirmed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isConfirmed
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
