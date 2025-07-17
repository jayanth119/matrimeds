import 'package:easy_localization/easy_localization.dart';
import 'package:matrimeds/services/tts_service.dart';

Future<void> speaker( String text) async {
  String lang = text.tr();


  // Speak the text using TTSService
  await TTSService.speak(lang);
}
