/// Represents one piece of drift evidence (a before/after quote pair).
/// Later: populated from LLM analysis output.
class DriftEvidence {
  final String timestamp;
  final String quote;
  final String stateLabel; // 'TENTATIVE' | 'ESTIMATE' | 'COMMITTED'
  final String commercialTerm; // e.g. 'Price: €18,000'

  const DriftEvidence({
    required this.timestamp,
    required this.quote,
    required this.stateLabel,
    required this.commercialTerm,
  });

  factory DriftEvidence.fromJson(Map<String, dynamic> json) {
    return DriftEvidence(
      timestamp:      json['timestamp']      as String,
      quote:          json['quote']          as String,
      stateLabel:     json['stateLabel']     as String,
      commercialTerm: json['commercialTerm'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp':      timestamp,
        'quote':          quote,
        'stateLabel':     stateLabel,
        'commercialTerm': commercialTerm,
      };
}