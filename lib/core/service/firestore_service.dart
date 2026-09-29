import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import 'dart:math';
import 'dart:html' as html;  // works on Flutter web only

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getSessionId() {
    const key = 'pg_session_id';
    String? id = html.window.localStorage[key];
    if (id != null && id.isNotEmpty) return id;
    id = _generateId();
    html.window.localStorage[key] = id;
    return id;
  }

  String _generateId() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (_) => rand.nextInt(256));
    return values.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<String> saveCall({
    required String callName,
    required String resolution,
    required bool driftDetected,
    required String commercialTerm,
    required String explanation,
    required String clarifyingQuestion,
    required List<AgreementItem> agreementItems,
  }) async {
    final docRef = await _db.collection('calls').add({
      'sessionId': _getSessionId(),
      'callName': callName,
      'resolution': resolution,
      'driftDetected': driftDetected,
      'commercialTerm': commercialTerm,
      'explanation': explanation,
      'clarifyingQuestion': clarifyingQuestion,
      'agreementItems': agreementItems.map((e) => e.toJson()).toList(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<QuerySnapshot> getPastCalls() {
    return _db
        .collection('calls')
        .where('sessionId', isEqualTo: _getSessionId())
        .snapshots();
  }
}