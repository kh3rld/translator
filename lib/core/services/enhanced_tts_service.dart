import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class EnhancedTTSService {
  static const MethodChannel _channel = MethodChannel('enhanced_tts');
  static final FlutterTts _flutterTts = FlutterTts();

  // Language-specific voice settings for more natural pronunciation
  static const Map<String, Map<String, dynamic>> _voiceSettings = {
    'EN': {
      'language': 'en-US',
      'pitch': 1.0,
      'rate': 0.5,
      'volume': 0.8,
      'voiceName': 'en-US-Standard-A',
    },
    'ES': {
      'language': 'es-ES',
      'pitch': 1.1,
      'rate': 0.5,
      'volume': 0.8,
      'voiceName': 'es-ES-Standard-A',
    },
    'FR': {
      'language': 'fr-FR',
      'pitch': 1.0,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'fr-FR-Standard-A',
    },
    'DE': {
      'language': 'de-DE',
      'pitch': 0.9,
      'rate': 0.5,
      'volume': 0.8,
      'voiceName': 'de-DE-Standard-A',
    },
    'IT': {
      'language': 'it-IT',
      'pitch': 1.1,
      'rate': 0.5,
      'volume': 0.8,
      'voiceName': 'it-IT-Standard-A',
    },
    'PT': {
      'language': 'pt-BR',
      'pitch': 1.0,
      'rate': 0.5,
      'volume': 0.8,
      'voiceName': 'pt-BR-Standard-A',
    },
    'RU': {
      'language': 'ru-RU',
      'pitch': 0.9,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'ru-RU-Standard-A',
    },
    'JA': {
      'language': 'ja-JP',
      'pitch': 1.0,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'ja-JP-Standard-A',
    },
    'KO': {
      'language': 'ko-KR',
      'pitch': 1.0,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'ko-KR-Standard-A',
    },
    'ZH': {
      'language': 'zh-CN',
      'pitch': 1.0,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'zh-CN-Standard-A',
    },
    'AR': {
      'language': 'ar-SA',
      'pitch': 0.9,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'ar-SA-Standard-A',
    },
    'HI': {
      'language': 'hi-IN',
      'pitch': 1.0,
      'rate': 0.4,
      'volume': 0.8,
      'voiceName': 'hi-IN-Standard-A',
    },
  };

  // Pronunciation tips for different languages
  static const Map<String, String> _pronunciationTips = {
    'EN': '💡 English tip: Stress the first syllable in most words',
    'ES': '💡 Spanish tip: Roll your R\'s and pronounce every letter',
    'FR': '💡 French tip: Nasal sounds are key - practice "bonjour"',
    'DE': '💡 German tip: Compound words are pronounced as one unit',
    'IT': '💡 Italian tip: Double consonants are held longer',
    'PT': '💡 Portuguese tip: Open and closed vowels make a difference',
    'RU': '💡 Russian tip: Stress can change word meaning completely',
    'JA': '💡 Japanese tip: Each syllable gets equal time',
    'KO': '💡 Korean tip: Consonant clusters are pronounced distinctly',
    'ZH': '💡 Chinese tip: Tones change word meaning - listen carefully',
    'AR': '💡 Arabic tip: Guttural sounds come from the back of throat',
    'HI': '💡 Hindi tip: Retroflex sounds are made with tongue tip curled',
  };

  // Fun pronunciation challenges
  static const Map<String, List<String>> _pronunciationChallenges = {
    'EN': [
      'The quick brown fox jumps over the lazy dog',
      'She sells seashells by the seashore',
      'How much wood would a woodchuck chuck?',
    ],
    'ES': [
      'El perro de San Roque no tiene rabo',
      'Tres tristes tigres comen trigo en un trigal',
      'Pablito clavó un clavito en la calva de un calvito',
    ],
    'FR': [
      'Un chasseur sachant chasser sait chasser sans son chien',
      'Les chaussettes de l\'archiduchesse sont-elles sèches?',
      'Si six scies scient six cyprès, six cent six scies scient six cent six cyprès',
    ],
    'DE': [
      'Fischers Fritze fischt frische Fische',
      'Blaukraut bleibt Blaukraut und Brautkleid bleibt Brautkleid',
      'Der Cottbuser Postkutscher putzt den Cottbuser Postkutschkasten',
    ],
    'IT': [
      'Trentatré trentini entrarono a Trento tutti e trentatré trotterellando',
      'Sopra la panca la capra campa, sotto la panca la capra crepa',
      'Tre tigri contro tre tigri',
    ],
  };

  /// Speak text with enhanced pronunciation
  static Future<void> speakText({
    required String text,
    required String languageCode,
    double? customPitch,
    double? customRate,
    double? customVolume,
  }) async {
    try {
      final settings = _voiceSettings[languageCode] ?? _voiceSettings['EN']!;

      await _channel.invokeMethod('speak', {
        'text': text,
        'language': settings['language'],
        'pitch': customPitch ?? settings['pitch'],
        'rate': customRate ?? settings['rate'],
        'volume': customVolume ?? settings['volume'],
        'voiceName': settings['voiceName'],
      });
    } catch (e) {
      debugPrint('TTS Error: $e');
      await _fallbackTTS(text, languageCode);
    }
  }

  /// Get pronunciation tip for a language
  static String getPronunciationTip(String languageCode) {
    return _pronunciationTips[languageCode] ??
        '💡 Listen carefully to the pronunciation and practice!';
  }

  /// Get pronunciation challenges for a language
  static List<String> getPronunciationChallenges(String languageCode) {
    return _pronunciationChallenges[languageCode] ??
        ['Practice makes perfect! Keep trying!'];
  }

  /// Speak with different emotions/tones
  static Future<void> speakWithEmotion({
    required String text,
    required String languageCode,
    required String emotion,
  }) async {
    try {
      final settings = _voiceSettings[languageCode] ?? _voiceSettings['EN']!;

      double pitch = settings['pitch'];
      double rate = settings['rate'];
      double volume = settings['volume'];

      switch (emotion) {
        case 'happy':
          pitch = 1.2;
          rate = 0.6;
          volume = 0.9;
          break;
        case 'sad':
          pitch = 0.8;
          rate = 0.3;
          volume = 0.7;
          break;
        case 'excited':
          pitch = 1.3;
          rate = 0.7;
          volume = 1.0;
          break;
        case 'calm':
          pitch = 0.9;
          rate = 0.4;
          volume = 0.8;
          break;
        case 'dramatic':
          pitch = 0.7;
          rate = 0.3;
          volume = 0.9;
          break;
      }

      await _channel.invokeMethod('speak', {
        'text': text,
        'language': settings['language'],
        'pitch': pitch,
        'rate': rate,
        'volume': volume,
        'voiceName': settings['voiceName'],
        'emotion': emotion,
      });
    } catch (e) {
      debugPrint('Emotional TTS Error: $e');
      await speakText(text: text, languageCode: languageCode);
    }
  }

  /// Speak text slowly for learning purposes
  static Future<void> speakSlowly({
    required String text,
    required String languageCode,
  }) async {
    await speakText(
      text: text,
      languageCode: languageCode,
      customRate: 0.3,
      customPitch: 1.0,
    );
  }

  /// Speak text with emphasis on each word
  static Future<void> speakWithEmphasis({
    required String text,
    required String languageCode,
  }) async {
    try {
      final words = text.split(' ');
      for (int i = 0; i < words.length; i++) {
        final word = words[i];
        await speakText(
          text: word,
          languageCode: languageCode,
          customRate: 0.4,
          customPitch: 1.1,
        );

        if (i < words.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      debugPrint('Emphasis TTS Error: $e');
      await speakText(text: text, languageCode: languageCode);
    }
  }

  /// Stop current speech
  static Future<void> stopSpeaking() async {
    try {
      await _channel.invokeMethod('stop');
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Stop TTS Error: $e');
    }
  }

  /// Check if TTS is available
  static Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod('isAvailable') ?? false;
    } catch (e) {
      debugPrint('TTS Availability Check Error: $e');
      return false;
    }
  }

  /// Get available voices for a language
  static Future<List<String>> getAvailableVoices(String languageCode) async {
    try {
      final voices = await _channel.invokeMethod('getVoices', {
        'language': languageCode,
      });
      return List<String>.from(voices ?? []);
    } catch (e) {
      debugPrint('Get Voices Error: $e');
      return [];
    }
  }

  /// Fallback TTS implementation
  static Future<void> _fallbackTTS(String text, String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Fallback TTS Error: $e');
    }
  }

  /// Get language-specific pronunciation guide
  static Map<String, String> getPronunciationGuide(String languageCode) {
    const guides = {
      'EN': {
        'th': 'Place tongue between teeth and blow air',
        'r': 'Curl tongue back without touching roof of mouth',
        'l': 'Touch tip of tongue to roof of mouth',
      },
      'ES': {
        'rr': 'Roll tongue rapidly against roof of mouth',
        'ñ': 'Say "ny" as in "canyon"',
        'll': 'Say "y" as in "yes"',
      },
      'FR': {
        'r': 'Gargle sound from back of throat',
        'u': 'Purse lips and say "ee"',
        'eu': 'Say "uh" with rounded lips',
      },
      'DE': {
        'ch': 'Clear throat sound',
        'ü': 'Say "ee" with rounded lips',
        'ö': 'Say "uh" with rounded lips',
      },
      'JA': {
        'r': 'Light tap of tongue on roof of mouth',
        'tsu': 'Say "ts" + "oo"',
        'fu': 'Say "fu" with lips barely touching',
      },
      'ZH': {
        'zh': 'Say "j" as in "measure"',
        'ch': 'Say "ch" as in "church"',
        'sh': 'Say "sh" as in "shoe"',
      },
    };

    return guides[languageCode] ?? {};
  }
}
