import 'package:promise_guard/core/config/commitment_state.dart';

class DriftEvidence {
  final String lineId;
  final String timestamp;
  final String speaker;
  final String quote;
  final CommitmentState? state;
  final String commercialTerm;

  const DriftEvidence({
    required this.lineId,
    required this.timestamp,
    required this.speaker,
    required this.quote,
    required this.state,
    required this.commercialTerm,
  });

  factory DriftEvidence.fromJson(Map<String, dynamic> json) {
    return DriftEvidence(
      lineId:         json['lineId']         as String? ?? '',
      timestamp:      json['timestamp']      as String? ?? '',
      speaker:        json['speaker']        as String? ?? '',
      quote:          json['quote']          as String? ?? '',
      state:          CommitmentState.fromLabel(json['stateLabel'] as String?),
      commercialTerm: json['commercialTerm'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'lineId':         lineId,
        'timestamp':      timestamp,
        'speaker':        speaker,
        'quote':          quote,
        'stateLabel':     state?.label ?? '',
        'commercialTerm': commercialTerm,
      };

  String get stateLabelDisplay => state?.displayName ?? 'Unknown';
}