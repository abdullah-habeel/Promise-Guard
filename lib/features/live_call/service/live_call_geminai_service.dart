import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:promise_guard/core/config/app_config.dart';
import 'package:promise_guard/features/live_call/service/live_drift_checker_service.dart';

class LiveGeminiChecker {
  /// Sends the last 15 lines to the lightweight analyzeDriftLive
  /// Cloud Function and returns a DriftCheckResult.
  static Future<DriftCheckResult> check(List<String> lines) async {
    try {
      // Take only last 15 lines
      final window = lines.length > 15
          ? lines.sublist(lines.length - 15)
          : lines;

      final response = await http.post(
        Uri.parse(AppConfig.analyzeDriftLiveUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lines': window}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return const DriftCheckResult(
          driftDetected: false,
          term: '',
          stateLabel: '',
          matchedLine: '',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return DriftCheckResult(
        driftDetected: data['driftDetected'] as bool? ?? false,
        term: data['commercialTerm'] as String? ?? '',
        stateLabel: data['stateLabel'] as String? ?? '',
        matchedLine: data['matchedLine'] as String? ?? '',
      );
    } catch (e) {
      // On any error fall back to no drift — never crash the live call
      return const DriftCheckResult(
        driftDetected: false,
        term: '',
        stateLabel: '',
        matchedLine: '',
      );
    }
  }
}