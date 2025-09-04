abstract class TranslationRepository {
  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  });

  Future<List<String>> getSupportedLanguages();

  Future<void> cacheTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  });

  Future<List<Map<String, dynamic>>> getTranslationHistory();
}
