import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/live_call_controller.dart';

class LiveCallScreen extends StatelessWidget {
  const LiveCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveCallController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Live Call',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status bar
          Obx(() => _StatusBar(
                isConnecting: controller.isConnecting.value,
                isRecording: controller.isRecording.value,
                status: controller.statusMessage.value,
                error: controller.errorMessage.value,
              )),

          // Transcript
          Expanded(
            child: Obx(() {
              if (controller.lines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_none_rounded,
                          size: 48, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Obx(() => Text(
                            controller.isRecording.value
                                ? 'Listening… start speaking'
                                : 'Press Start Call to begin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          )),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.lines.length,
                itemBuilder: (_, i) =>
                    _LineWidget(line: controller.lines[i]),
              );
            }),
          ),

          // Controls
          Obx(() => _Controls(
                isConnecting: controller.isConnecting.value,
                isRecording: controller.isRecording.value,
                isEnding: controller.isEnding.value,
                onStart: controller.startCall,
                onEnd: controller.endCall,
              )),
        ],
      ),
    );
  }
}

// ── Status Bar ────────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final bool isConnecting;
  final bool isRecording;
  final String status;
  final String error;

  const _StatusBar({
    required this.isConnecting,
    required this.isRecording,
    required this.status,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: hasError
          ? const Color(0xFF3B0A0A)
          : isRecording
              ? const Color(0xFF0A2E1E)
              : const Color(0xFF161B22),
      child: Row(
        children: [
          if (isConnecting || isRecording) ...[
            _PulseDot(
                color: isRecording
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              hasError ? error : status,
              style: TextStyle(
                color: hasError
                    ? const Color(0xFFF87171)
                    : Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ── Transcript Line ───────────────────────────────────────────────────────────

class _LineWidget extends StatelessWidget {
  final LiveTranscriptLine line;
  const _LineWidget({required this.line});

  Color _color(String speaker) {
    final palette = [
      const Color(0xFF60A5FA),
      const Color(0xFF34D399),
      const Color(0xFFFBBF24),
      const Color(0xFFA78BFA),
    ];
    final hash = speaker.codeUnits.fold(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(line.speaker);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              line.speaker.replaceFirst('Speaker ', 'Spkr '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => Text(
                  line.text.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

// ── Controls ──────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final bool isConnecting;
  final bool isRecording;
  final bool isEnding;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  const _Controls({
    required this.isConnecting,
    required this.isRecording,
    required this.isEnding,
    required this.onStart,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      color: const Color(0xFF161B22),
      child: SizedBox(
        width: double.infinity,
        child: !isRecording
            ? FilledButton.icon(
                onPressed: isConnecting ? null : onStart,
                icon: isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.mic_rounded),
                label: Text(isConnecting ? 'Connecting…' : 'Start Call'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E9E8E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            : FilledButton.icon(
                onPressed: isEnding ? null : onEnd,
                icon: isEnding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.stop_rounded),
                label: Text(isEnding ? 'Analyzing…' : 'End Call'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }
}