import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final shareText =
          '''
Original Text ($sourceLang):
$originalText

Translated Text ($targetLang):
$translatedText

Shared from Translator App
      '''
              .trim();

      await Share.share(
        shareText,
        subject: 'Translation from $sourceLang to $targetLang',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Share error: $e');
      }
    }
  }
}
