import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool isAvailable = false;
  bool isListening = false;
  String recognizedText = '';

  Future<void> init() async {
    isAvailable = await _speech.initialize(
      onError: (e) => print('STT Error: $e'),
      onStatus: (s) => print('STT Status: $s'),
    );
  }

  Future<void> startListening({required void Function(String) onResult}) async {
    if (!isAvailable) return;
    recognizedText = '';
    isListening = true;
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        recognizedText = result.recognizedWords;
        onResult(recognizedText);
      },
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    if (!isListening) return;
    await _speech.stop();
    isListening = false;
  }
}