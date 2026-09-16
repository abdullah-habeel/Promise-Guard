import 'package:flutter/material.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';

class ChatBubble extends StatelessWidget {
  final TranscriptLine line;

  const ChatBubble({super.key, required this.line});

  bool get _isCustomer => line.role == 'customer';

  @override
  Widget build(BuildContext context) {
    final bubbleColor = _isCustomer
        ? const Color(0xFFE8EDF5)
        : const Color(0xFF1B4F72);
    final textColor  = _isCustomer ? const Color(0xFF1A1A2E) : Colors.white;
    final metaColor  = _isCustomer ? const Color(0xFF6B7280) : Colors.white60;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            _isCustomer ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isCustomer) ...[
            _Avatar(label: 'C', color: const Color(0xFF0E9E8E)),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(_isCustomer ? 4 : 16),
                  bottomRight: Radius.circular(_isCustomer ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: _isCustomer
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        line.speaker,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: metaColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        line.time,
                        style: TextStyle(fontSize: 11, color: metaColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    line.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!_isCustomer) ...[
            const SizedBox(width: 8),
            _Avatar(label: 'S', color: const Color(0xFF1B4F72)),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String label;
  final Color color;

  const _Avatar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}