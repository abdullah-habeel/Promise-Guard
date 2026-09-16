/// One agreed commercial term in the record.
/// Later: parsed from LLM structured output.
class AgreementItem {
  final String item;
  final String value;
  final String evidence;
  final String participants;

  const AgreementItem({
    required this.item,
    required this.value,
    required this.evidence,
    required this.participants,
  });

  factory AgreementItem.fromJson(Map<String, dynamic> json) {
    return AgreementItem(
      item:         json['item']         as String,
      value:        json['value']        as String,
      evidence:     json['evidence']     as String,
      participants: json['participants'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'item':         item,
        'value':        value,
        'evidence':     evidence,
        'participants': participants,
      };
}