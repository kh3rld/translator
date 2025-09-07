import '../../core/services/local_translation_service.dart';
import '../../core/errors/app_exceptions.dart';

class TranslationLocalDataSource {
  final LocalTranslationService _localTranslationService;

  TranslationLocalDataSource({required LocalTranslationService localTranslationService})
      : _localTranslationService = localTranslationService;

  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      return await _localTranslationService.translateText(
        text: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    } catch (e) {
      throw ApiException('Local translation failed: $e');
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    return _localTranslationService.getSupportedLanguages();
  }

  Future<bool> downloadLanguageModel(String languageCode) async {
    return await _localTranslationService.downloadLanguageModel(languageCode);
  }

  Future<bool> isModelDownloaded(String languageCode) async {
    return await _localTranslationService.isModelDownloaded(languageCode);
  }

  Future<bool> deleteLanguageModel(String languageCode) async {
    return await _localTranslationService.deleteLanguageModel(languageCode);
  }

  Future<List<String>> getDownloadedModels() async {
    return await _localTranslationService.getDownloadedModels();
  }
}
