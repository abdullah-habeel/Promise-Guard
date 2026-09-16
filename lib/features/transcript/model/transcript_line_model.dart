/// A single utterance in the call transcript.
/// Later: map from AssemblyAI utterance JSON.
class TranscriptLine {
  final String time;
  final String speaker;
  final String role; // 'customer' | 'salesperson'
  final String text;

  const TranscriptLine({
    required this.time,
    required this.speaker,
    required this.role,
    required this.text,
  });

  factory TranscriptLine.fromJson(Map<String, dynamic> json) {
    return TranscriptLine(
      time:    json['time']    as String,
      speaker: json['speaker'] as String,
      role:    json['role']    as String,
      text:    json['text']    as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'time':    time,
        'speaker': speaker,
        'role':    role,
        'text':    text,
      };
}