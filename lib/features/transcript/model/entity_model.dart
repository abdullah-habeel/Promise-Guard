class DetectedEntity {
  final String text;
  final String entityType;

  const DetectedEntity({
    required this.text,
    required this.entityType,
  });

  factory DetectedEntity.fromJson(Map<String, dynamic> json) {
    return DetectedEntity(
      text: json['text'] as String,
      entityType: json['entity_type'] as String,
    );
  }

  String get typeLabel {
    switch (entityType) {
      case 'money_amount':
        return 'Amount';
      case 'date':
        return 'Date';
      case 'person_name':
        return 'Person';
      case 'organization':
        return 'Organization';
      case 'location':
        return 'Location';
      case 'product':
        return 'Product';
      case 'occupation':
        return 'Role';
      default:
        return 'Detected';
    }
  }

  String get emoji {
    switch (entityType) {
      case 'money_amount':
        return '💰';
      case 'date':
        return '📅';
      case 'person_name':
        return '👤';
      case 'organization':
        return '🏢';
      case 'location':
        return '📍';
      case 'product':
        return '📦';
      case 'occupation':
        return '👔';
      default:
        return '🔍';
    }
  }

  String get displayLabel => '$emoji $typeLabel: $text';
}