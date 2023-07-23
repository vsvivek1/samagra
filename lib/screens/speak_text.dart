import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

void speakText(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.speak(text);
}

// prasan@205

// prasan@205