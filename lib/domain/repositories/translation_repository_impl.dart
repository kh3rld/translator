import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'translation_repository.dart';
import '../../data/datasources/translation_hybrid_data_source.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationHybridDataSource dataSource;

  TranslationRepositoryImpl({required this.dataSource});

  @override
  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    return await dataSource.translateText(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    return await dataSource.getSupportedLanguages();
  }

  @override
  Future<void> cacheTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('translation_history') ?? [];

    final translationData = {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'timestamp': DateTime.now().toIso8601String(),
    };

    history.add(json.encode(translationData));
    await prefs.setStringList('translation_history', history);
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('translation_history') ?? [];

    return history.map((item) {
      return json.decode(item) as Map<String, dynamic>;
    }).toList();
  }
}