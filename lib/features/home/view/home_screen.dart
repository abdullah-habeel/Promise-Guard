import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/core/service/firestore_service.dart';
import 'package:promise_guard/core/theme/app_theme.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final firestoreService = FirestoreService();

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNavBar(),
                    const SizedBox(height: 40),
                    _buildHero(),
                    const SizedBox(height: 32),
                    _buildMainCard(controller),
                    const SizedBox(height: 32),
                    _buildPastCalls(firestoreService),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          'PromiseGuard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 13, color: Colors.white),
              SizedBox(width: 5),
               Text(
                'AI-Powered Commitment Tracking',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 16),
        Text(
  'Good conversations should hold up.',
  style: GoogleFonts.playfairDisplay(
    fontSize: 36,
    height: 1.1,
    letterSpacing: -1.2,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  ),
),
        const SizedBox(height: 12),
        Text(
          'Turn the details of every call into clear, dependable commitments.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.75),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.emerald,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'START WITH A CALL',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Call name input
          TextField(
            onChanged: (v) => controller.callName.value = v,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'Call name (optional)',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              prefixIcon: const Icon(Icons.label_outline_rounded, size: 18, color: Color(0xFF6B7280)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.emerald, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // File picker
          Obx(() => GestureDetector(
            onTap: controller.pickFile,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: controller.fileName.value.isEmpty
                    ? Colors.white
                    : AppTheme.emerald.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.fileName.value.isEmpty
                      ? const Color(0xFFD1D5DB)
                      : AppTheme.emerald.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: controller.fileName.value.isEmpty
                          ? const Color(0xFFF3F4F6)
                          : AppTheme.emerald.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.fileName.value.isEmpty
                          ? Icons.upload_file_outlined
                          : Icons.audio_file_outlined,
                      size: 22,
                      color: controller.fileName.value.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : AppTheme.emerald,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.fileName.value.isEmpty
                        ? 'Click to upload audio file'
                        : controller.fileName.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: controller.fileName.value.isEmpty
                          ? const Color(0xFF6B7280)
                          : AppTheme.emerald,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'MP3, WAV, M4A supported',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 20),

          // OR divider
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('or', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              ),
              Expanded(child: Divider(color: Color(0xFFD1D5DB), thickness: 1)),
            ],
          ),
          const SizedBox(height: 14),

          // Live Call button
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(
              AppRoutes.liveCall,
              arguments: {'callName': controller.callName.value},
            ),
            icon: const Icon(Icons.mic_rounded, size: 18, color: Color(0xFF1A1A2E)),
            label: const Text(
              'Start Live Call',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.cyanAccent.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          // Analyze button
          Obx(() => FilledButton.icon(
            onPressed: controller.fileName.value.isEmpty
                ? null
                : controller.startAnalysis,
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text(
              'Analyze Call',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.emerald,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPastCalls(FirestoreService firestoreService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Past Calls',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getPastCalls(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getPastCalls(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 30, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(height: 10),
                    Text(
                      'No past calls yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analyze your first call above.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs.toList()
              ..sort((a, b) {
                final aT = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                final bT = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                return bT.compareTo(aT);
              });

            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final callName = data['callName'] as String? ?? 'Untitled Call';
                    final resolution = data['resolution'] as String? ?? 'pending';
                    final driftDetected = data['driftDetected'] as bool? ?? false;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final date = timestamp != null ? _formatDate(timestamp.toDate()) : 'Just now';
                    final isConfirmed = resolution == 'confirmed';

                    return InkWell(
                    onTap: () => Get.toNamed(AppRoutes.history, arguments: {'docId': docs[index].id}),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: driftDetected
                                    ? const Color(0xFFFFF3E0)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                driftDetected
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline_rounded,
                                color: driftDetected
                                    ? const Color(0xFFE65100)
                                    : const Color(0xFF16A34A),
                                size: 18,
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
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isConfirmed
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFFBD38D),
                                ),
                              ),
                              child: Text(
                                isConfirmed ? 'Confirmed' : 'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isConfirmed
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}