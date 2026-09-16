import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:promise_guard/core/config/app_config.dart';
import 'package:promise_guard/features/transcript/model/entity_model.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';

class TranscriptService {
  // Upload audio bytes and get transcript_id
  Future<String> uploadAudio(Uint8List audioBytes) async {
    final response = await http.post(
      Uri.parse(AppConfig.transcribeAudioUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: audioBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final transcriptId = data['transcript_id'];

    if (transcriptId == null) {
      throw Exception('No transcript_id returned: ${response.body}');
    }

    return transcriptId as String;
  }

  // Poll until status is completed or error
  Future<Map<String, dynamic>> pollTranscript(String transcriptId) async {
    while (true) {
      final response = await http.get(
        Uri.parse('${AppConfig.getTranscriptUrl}?id=$transcriptId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Poll failed: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String;

      if (status == 'completed') return data;
      if (status == 'error')
        throw Exception('Transcription error: ${data['error']}');

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  // Map AssemblyAI utterances to our TranscriptLine model
  List<TranscriptLine> parseUtterances(Map<String, dynamic> data) {
    final utterances = data['utterances'] as List<dynamic>? ?? [];

    return utterances.map((u) {
      final speaker = u['speaker'] as String;
      final startMs = u['start'] as int;
      final text = u['text'] as String;

      final totalSeconds = startMs ~/ 1000;
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      final time =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      final isCustomer = speaker == 'A';

      return TranscriptLine(
        time: time,
        speaker: isCustomer ? 'Customer' : 'Salesperson',
        role: isCustomer ? 'customer' : 'salesperson',
        text: text,
      );
    }).toList();
  }

  // Parse AssemblyAI entity detection results
  List<DetectedEntity> parseEntities(Map<String, dynamic> data) {
    final entities = data['entities'] as List<dynamic>? ?? [];

    // Deduplicate by text so we don't show the same entity twice
    final seen = <String>{};
    final result = <DetectedEntity>[];

    for (final e in entities) {
      final entity = DetectedEntity.fromJson(e as Map<String, dynamic>);
      if (seen.add(entity.text.toLowerCase())) {
        result.add(entity);
      }
    }

    return result;
  }
}
