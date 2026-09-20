import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:promise_guard/core/config/app_config.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/transcript/model/transcript_line_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class LiveTranscriptLine {
  final String speaker;
  final RxString text;

  LiveTranscriptLine({required this.speaker, required String initialText})
      : text = initialText.obs;
}

class LiveCallController extends GetxController {
  final RxBool isConnecting = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isEnding = false.obs;
  final RxString statusMessage = 'Ready to start'.obs;
  final RxString errorMessage = ''.obs;
  final RxList<LiveTranscriptLine> lines = <LiveTranscriptLine>[].obs;
  final RxString callName = ''.obs;

  WebSocketChannel? _channel;
  web.MediaStream? _micStream;
  web.AudioContext? _audioContext;
  web.ScriptProcessorNode? _processor;
  web.MediaStreamAudioSourceNode? _source;
  StreamSubscription? _wsSub;

  final Map<String, int> _openLineIndex = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      callName.value = args['callName'] as String? ?? '';
    }
  }

  Future<void> startCall() async {
    errorMessage.value = '';
    isConnecting.value = true;
    statusMessage.value = 'Requesting microphone…';

    try {
      // 1. Get microphone
      _micStream = await _getUserMedia();
      statusMessage.value = 'Fetching streaming token…';

      // 2. Get token from Cloud Function
      final token = await _fetchStreamingToken();
      statusMessage.value = 'Connecting to AssemblyAI…';

      // 3. Connect WebSocket
      final uri = Uri.parse(
        'wss://streaming.assemblyai.com/v3/ws'
        '?sample_rate=16000'
        '&encoding=pcm_s16le'
        '&language_code=en'
        '&speaker_labels=true'
        '&token=$token',
      );
      _channel = WebSocketChannel.connect(uri);
      _wsSub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // 4. Start Web Audio API — sends raw PCM to WebSocket
      await _startAudioCapture();

      isConnecting.value = false;
      isRecording.value = true;
      statusMessage.value = 'Recording… speak now';
    } catch (e) {
      isConnecting.value = false;
      errorMessage.value = 'Failed to start: $e';
      statusMessage.value = 'Error — try again';
      _cleanup();
    }
  }

  Future<void> _startAudioCapture() async {
    // Create AudioContext at 16kHz to match WebSocket declaration
    _audioContext = web.AudioContext(
      web.AudioContextOptions(sampleRate: 16000),
    );

    // Connect mic stream to audio graph
    _source = _audioContext!.createMediaStreamSource(_micStream!);

    // ScriptProcessorNode gives us raw Float32 PCM chunks
    // bufferSize 4096, 1 input channel, 1 output channel
    _processor = _audioContext!.createScriptProcessor(4096, 1, 1);

    _processor!.addEventListener(
  'audioprocess',
  (web.Event event) {
    if (!isRecording.value) return;
    final audioEvent = event as web.AudioProcessingEvent;
    final channelData = audioEvent.inputBuffer.getChannelData(0);
    final pcmBytes = _float32ToInt16Bytes(channelData);
    _channel?.sink.add(pcmBytes);
  }.toJS,
);

    _source!.connect(_processor!);
    // Must connect to destination to keep the graph running
    _processor!.connect(_audioContext!.destination);
  }

  Uint8List _float32ToInt16Bytes(JSFloat32Array float32) {
  final floatList = float32.toDart;
  final length = floatList.length;
  final byteData = ByteData(length * 2);

  for (int i = 0; i < length; i++) {
    final sample = (floatList[i] * 32767.0).clamp(-32768.0, 32767.0).toInt();
    byteData.setInt16(i * 2, sample, Endian.little);
  }

  return byteData.buffer.asUint8List();
}

  Future<void> endCall() async {
    if (isEnding.value) return;
    isEnding.value = true;
    statusMessage.value = 'Processing…';

    // Stop audio capture
    _stopAudioCapture();

    // Tell AssemblyAI to flush
    try {
      _channel?.sink.add(jsonEncode({'terminate_session': true}));
    } catch (_) {}

    // Wait for final transcripts
    await Future.delayed(const Duration(milliseconds: 1500));
    await _channel?.sink.close();
    await _wsSub?.cancel();

    // Stop mic
    _micStream?.getTracks().toDart.forEach((t) => t.stop());

    isRecording.value = false;

    final transcriptLines = _buildTranscriptLines();

    if (transcriptLines.isEmpty) {
      errorMessage.value = 'No speech detected. Please try again.';
      isEnding.value = false;
      statusMessage.value = 'Ready to start';
      return;
    }

    Get.toNamed(
      AppRoutes.driftAlert,
      arguments: {
        'callName': callName.value.isEmpty ? 'Live Call' : callName.value,
        'transcriptLines': transcriptLines,
      },
    );
  }

  void _stopAudioCapture() {
    _processor?.disconnect();
    _source?.disconnect();
    _audioContext?.close().toDart;
    _processor = null;
    _source = null;
    _audioContext = null;
  }

  Future<web.MediaStream> _getUserMedia() async {
    final constraints = web.MediaStreamConstraints(
      audio: true.toJS,
      video: false.toJS,
    );
    return web.window.navigator.mediaDevices.getUserMedia(constraints).toDart;
  }

  Future<String> _fetchStreamingToken() async {
    final response = await http.post(
      Uri.parse(AppConfig.getStreamingTokenUrl),
    );
    if (response.statusCode != 200) {
      throw Exception('Token fetch failed: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Empty token received');
    }
    return token;
  }

  void _onMessage(dynamic raw) {
  try {
    final msg = jsonDecode(raw as String) as Map<String, dynamic>;
    final type = msg['type'] as String?;

    if (type == 'Turn') {
      final text = (msg['transcript'] as String? ?? '').trim();
      if (text.isEmpty) return;

      final isFinal = msg['end_of_turn'] as bool? ?? false;
      final speakerLabel = msg['speaker_label'] as String? ?? 'A';
      final speaker = speakerLabel == 'PENDING' ? 'Speaker A' : 'Speaker $speakerLabel';

      if (isFinal) {
        _commitLine(speaker, text);
      } else {
        _updatePartial(speaker, text);
      }
    }

    if (type == 'error') {
      errorMessage.value = msg['error']?.toString() ?? 'Unknown error';
    }
  } catch (_) {}
}

  void _updatePartial(String speaker, String text) {
    final idx = _openLineIndex[speaker];
    if (idx != null && idx < lines.length) {
      lines[idx].text.value = text;
    } else {
      final newIdx = lines.length;
      lines.add(LiveTranscriptLine(speaker: speaker, initialText: text));
      _openLineIndex[speaker] = newIdx;
    }
  }

  void _commitLine(String speaker, String text) {
    final idx = _openLineIndex[speaker];
    if (idx != null && idx < lines.length) {
      lines[idx].text.value = text;
    } else {
      lines.add(LiveTranscriptLine(speaker: speaker, initialText: text));
    }
    _openLineIndex.remove(speaker);
  }

  List<TranscriptLine> _buildTranscriptLines() {
    final result = <TranscriptLine>[];
    for (int i = 0; i < lines.length; i++) {
      final t = lines[i].text.value.trim();
      if (t.isEmpty) continue;
      result.add(TranscriptLine(
        time: '00:${i.toString().padLeft(2, '0')}',
        speaker: lines[i].speaker,
        role: lines[i].speaker == 'Speaker A' ? 'salesperson' : 'customer',
        text: t,
      ));
    }
    return result;
  }

  void _onError(Object err) {
    errorMessage.value = 'Connection error: $err';
    isRecording.value = false;
    isEnding.value = false;
  }

  void _onDone() {
    if (isRecording.value) {
      isRecording.value = false;
      statusMessage.value = 'Connection closed';
    }
  }

  void _cleanup() {
    _stopAudioCapture();
    _micStream?.getTracks().toDart.forEach((t) => t.stop());
    _wsSub?.cancel();
    _channel?.sink.close();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }
}