import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalTranslationService {
  static const String _downloadedModelsKey = 'downloaded_translation_models';

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();
  final Map<String, OnDeviceTranslator> _translators = {};
  final Map<String, bool> _downloadedModels = {};

  // Language code mapping from our app constants to ML Kit language codes
  // Only including languages that are actually supported by Google ML Kit
  static final Map<String, TranslateLanguage> _languageMapping = {
    'EN': TranslateLanguage.english,
    'ES': TranslateLanguage.spanish,
    'FR': TranslateLanguage.french,
    'DE': TranslateLanguage.german,
    'IT': TranslateLanguage.italian,
    'PT': TranslateLanguage.portuguese,
    'RU': TranslateLanguage.russian,
    'JA': TranslateLanguage.japanese,
    'KO': TranslateLanguage.korean,
    'ZH': TranslateLanguage.chinese,
    'AR': TranslateLanguage.arabic,
    'HI': TranslateLanguage.hindi,
    'TH': TranslateLanguage.thai,
    'VI': TranslateLanguage.vietnamese,
    'TR': TranslateLanguage.turkish,
    'PL': TranslateLanguage.polish,
    'NL': TranslateLanguage.dutch,
    'SV': TranslateLanguage.swedish,
    'DA': TranslateLanguage.danish,
    'NO': TranslateLanguage.norwegian,
    'FI': TranslateLanguage.finnish,
    'CS': TranslateLanguage.czech,
    'HU': TranslateLanguage.hungarian,
    'RO': TranslateLanguage.romanian,
    'BG': TranslateLanguage.bulgarian,
    'HR': TranslateLanguage.croatian,
    'SK': TranslateLanguage.slovak,
    'SL': TranslateLanguage.slovenian,
    'ET': TranslateLanguage.estonian,
    'LV': TranslateLanguage.latvian,
    'LT': TranslateLanguage.lithuanian,
    'EL': TranslateLanguage.greek,
    'HE': TranslateLanguage.hebrew,
    'ID': TranslateLanguage.indonesian,
    'MS': TranslateLanguage.malay,
    'SW': TranslateLanguage.swahili,
    'AF': TranslateLanguage.afrikaans,
    'IS': TranslateLanguage.icelandic,
    'GA': TranslateLanguage.irish,
    'CY': TranslateLanguage.welsh,
    'MT': TranslateLanguage.maltese,
    'CA': TranslateLanguage.catalan,
    'GL': TranslateLanguage.galician,
  };

  /// Initialize the service and download required models
  Future<void> initialize() async {
    await _loadDownloadedModels();
    await _preloadCommonModels();
  }

  /// Download language models for offline translation
  Future<bool> downloadLanguageModel(String languageCode) async {
    try {
      final mlKitLanguage = _languageMapping[languageCode.toUpperCase()];
      if (mlKitLanguage == null) {
        throw Exception('Unsupported language: $languageCode');
      }

      final isDownloaded =
          await _modelManager.downloadModel(mlKitLanguage.bcpCode);
      if (isDownloaded) {
        await _saveDownloadedModel(languageCode);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if a language model is downloaded
  Future<bool> isModelDownloaded(String languageCode) async {
    try {
      final mlKitLanguage = _languageMapping[languageCode.toUpperCase()];
      if (mlKitLanguage == null) return false;

      if (_downloadedModels.containsKey(languageCode)) {
        return _downloadedModels[languageCode]!;
      }

      final isDownloaded =
          await _modelManager.isModelDownloaded(mlKitLanguage.bcpCode);
      _downloadedModels[languageCode] = isDownloaded;
      return isDownloaded;
    } catch (e) {
      return false;
    }
  }

  /// Delete a language model to free up space
  Future<bool> deleteLanguageModel(String languageCode) async {
    try {
      final mlKitLanguage = _languageMapping[languageCode.toUpperCase()];
      if (mlKitLanguage == null) return false;

      final isDeleted = await _modelManager.deleteModel(mlKitLanguage.bcpCode);
      if (isDeleted) {
        await _removeDownloadedModel(languageCode);
        _translators.remove('${languageCode}_translator');
      }
      return isDeleted;
    } catch (e) {
      return false;
    }
  }

  /// Translate text using local models
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final sourceModelDownloaded = await isModelDownloaded(sourceLanguage);
      final targetModelDownloaded = await isModelDownloaded(targetLanguage);

      if (!sourceModelDownloaded || !targetModelDownloaded) {
        throw Exception(
            'Required language models not downloaded. Please download models for $sourceLanguage and $targetLanguage first.');
      }

      final translatorKey = '${sourceLanguage}_$targetLanguage';
      if (!_translators.containsKey(translatorKey)) {
        final sourceLang = _languageMapping[sourceLanguage.toUpperCase()];
        final targetLang = _languageMapping[targetLanguage.toUpperCase()];

        if (sourceLang == null || targetLang == null) {
          throw Exception(
              'Unsupported language pair: $sourceLanguage -> $targetLanguage');
        }

        _translators[translatorKey] = OnDeviceTranslator(
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
        );
      }

      final translator = _translators[translatorKey]!;
      final translatedText = await translator.translateText(text);

      return translatedText;
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }

  /// Get list of downloaded models
  Future<List<String>> getDownloadedModels() async {
    final downloadedModels = <String>[];
    for (final entry in _downloadedModels.entries) {
      if (entry.value) {
        downloadedModels.add(entry.key);
      }
    }
    return downloadedModels;
  }

  /// Get available language pairs for translation
  List<String> getSupportedLanguages() {
    return _languageMapping.keys.toList();
  }

  /// Close all translators to free up resources
  Future<void> dispose() async {
    for (final translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
  }

  // Private methods for persistence
  Future<void> _loadDownloadedModels() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedModels = prefs.getStringList(_downloadedModelsKey) ?? [];

    for (final languageCode in downloadedModels) {
      if (_languageMapping.containsKey(languageCode.toUpperCase())) {
        _downloadedModels[languageCode] = true;
      }
    }
  }

  /// Preload common language models for better user experience
  Future<void> _preloadCommonModels() async {
    final commonLanguages = ['EN', 'ES'];

    for (final langCode in commonLanguages) {
      if (!await isModelDownloaded(langCode)) {
        downloadLanguageModel(langCode).catchError((e) {
          return false;
        });
      }
    }
  }

  Future<void> _saveDownloadedModel(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedModels = prefs.getStringList(_downloadedModelsKey) ?? [];
    if (!downloadedModels.contains(languageCode)) {
      downloadedModels.add(languageCode);
      await prefs.setStringList(_downloadedModelsKey, downloadedModels);
    }
  }

  Future<void> _removeDownloadedModel(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedModels = prefs.getStringList(_downloadedModelsKey) ?? [];
    downloadedModels.remove(languageCode);
    await prefs.setStringList(_downloadedModelsKey, downloadedModels);
  }
}
