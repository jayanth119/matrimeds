import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();

  /// Initialize TTS with saved language
  static Future<void> initTTS() async {
    String languageCode = await _getLanguageFromPrefs();
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Speak a given text in the selected language
  static Future<void> speak(String text) async {
    String languageCode = await _getLanguageFromPrefs();
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  /// Stop speaking
  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Get app language and map to TTS language
  static Future<String> _getLanguageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String appLang = prefs.getString('app_language') ?? 'en';

    switch (appLang) {
      case 'hi':
        return 'hi-IN'; // Hindi
      case 'te':
        return 'te-IN'; // Telugu
      default:
        return 'en-US'; // English
    }
  }
}
