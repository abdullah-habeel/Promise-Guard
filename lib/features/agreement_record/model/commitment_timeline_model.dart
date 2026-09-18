import 'package:promise_guard/core/config/commitment_state.dart';

class CommitmentTimelineEntry {
  final String lineId;
  final String timestamp;
  final String speaker;
  final CommitmentState? state;
  final String quote;

  const CommitmentTimelineEntry({
    required this.lineId,
    required this.timestamp,
    required this.speaker,
    required this.state,
    required this.quote,
  });

  factory CommitmentTimelineEntry.fromJson(Map<String, dynamic> json) {
    return CommitmentTimelineEntry(
      lineId:    json['lineId']    as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      speaker:   json['speaker']   as String? ?? '',
      state:     CommitmentState.fromLabel(json['state'] as String?),
      quote:     json['quote']     as String? ?? '',
    );
  }

  String get stateLabelDisplay => state?.displayName ?? 'Unknown';
}