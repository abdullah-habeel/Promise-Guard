import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:promise_guard/features/agreement_record/model/agreement_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getUserId() {
    final user = _auth.currentUser;
    if (user != null) return user.uid;
    return _getGuestId();
  }

  String _guestId = '';

  String _getGuestId() {
    if (_guestId.isNotEmpty) return _guestId;
    _guestId = _generateId();
    return _guestId;
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
    final userId = _getUserId();
    final docRef = await _db.collection('calls').add({
      'userId': userId,
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
    final userId = _getUserId();
    return _db
        .collection('calls')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = (a['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        final bTime = (b['timestamp'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });
      return snapshot;
    });
  }
}