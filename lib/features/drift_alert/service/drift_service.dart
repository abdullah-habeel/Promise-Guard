import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promise_guard/core/config/app_config.dart';
import 'package:promise_guard/features/drift_alert/model/drift_evidence_model.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';

class DriftService {
  Future<Map<String, dynamic>> analyzeDrift(
      List<TranscriptLine> transcriptLines) async {
    final transcript = transcriptLines
        .map((line) => {
              'time': line.time,
              'speaker': line.speaker,
              'text': line.text,
            })
        .toList();

    final response = await http.post(
      Uri.parse(AppConfig.analyzeDriftUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transcript': transcript}),
    );

    if (response.statusCode != 200) {
      throw Exception('Drift analysis failed: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<DriftEvidence> parseEvidence(Map<String, dynamic> data) {
    final evidenceList = data['evidence'] as List<dynamic>? ?? [];
    return evidenceList
        .map((e) => DriftEvidence.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}