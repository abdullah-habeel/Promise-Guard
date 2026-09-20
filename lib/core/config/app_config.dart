class AppConfig {
  AppConfig._();

  static const transcribeAudioUrl =
      'https://us-central1-promise-guard.cloudfunctions.net/transcribeAudio';

  static const getTranscriptUrl =
      'https://us-central1-promise-guard.cloudfunctions.net/getTranscript';

  static const analyzeDriftUrl =
      'https://us-central1-promise-guard.cloudfunctions.net/analyzeDrift';
      static const getStreamingTokenUrl =
    'https://us-central1-promise-guard.cloudfunctions.net/getStreamingToken';
}