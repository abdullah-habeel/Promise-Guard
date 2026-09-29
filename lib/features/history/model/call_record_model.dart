import 'package:cloud_firestore/cloud_firestore.dart';

class CallRecordModel {
  final String docId;
  final String callName;
  final String resolution;
  final bool driftDetected;
  final String commercialTerm;
  final String explanation;
  final String clarifyingQuestion;
  final DateTime? timestamp;

  CallRecordModel({
    required this.docId,
    required this.callName,
    required this.resolution,
    required this.driftDetected,
    required this.commercialTerm,
    required this.explanation,
    required this.clarifyingQuestion,
    this.timestamp,
  });

  factory CallRecordModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CallRecordModel(
      docId: doc.id,
      callName: d['callName'] as String? ?? 'Untitled Call',
      resolution: d['resolution'] as String? ?? 'pending',
      driftDetected: d['driftDetected'] as bool? ?? false,
      commercialTerm: d['commercialTerm'] as String? ?? '',
      explanation: d['explanation'] as String? ?? '',
      clarifyingQuestion: d['clarifyingQuestion'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}