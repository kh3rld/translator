import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';

class TextToSpeechService {
  static const MethodChannel _channel = MethodChannel('text_to_speech');

  static Future<void> speak(String text, String language) async {
    try {
      await _channel.invokeMethod('speak', {
        'text': text,
        'language': language,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Text-to-speech error: ${e.message}');
      }
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Stop speech error: ${e.message}');
      }
    }
  }
}
