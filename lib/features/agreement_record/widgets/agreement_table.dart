import 'package:flutter/material.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import '../../../../core/theme/app_theme.dart';

class AgreementTable extends StatelessWidget {
  final List<AgreementItem> items;
  final String resolutionStatus;

  const AgreementTable({
    super.key,
    required this.items,
    required this.resolutionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _TableHeader(),
          const Divider(height: 1),
          ...items.map(
            (item) => _TableRow(
              item: item,
              resolutionStatus: resolutionStatus,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF6B7280),
      letterSpacing: 0.6,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('ITEM',         style: style)),
          Expanded(flex: 2, child: Text('VALUE',        style: style)),
          Expanded(flex: 3, child: Text('STATUS',       style: style)),
          Expanded(flex: 2, child: Text('EVIDENCE',     style: style)),
          Expanded(flex: 3, child: Text('PARTICIPANTS', style: style)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final AgreementItem item;
  final String resolutionStatus;

  const _TableRow({required this.item, required this.resolutionStatus});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (resolutionStatus) {
      'confirmed'     => ('✅ Confirmed',     AppTheme.confirmed,    const Color(0xFFDCFCE7)),
      'not_confirmed' => ('❌ Not Confirmed', AppTheme.notConfirmed, const Color(0xFFFFE4E6)),
      _               => ('⏳ Pending',       AppTheme.pending,      const Color(0xFFF3F4F6)),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item.item,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.evidence,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.participants,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}