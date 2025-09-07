import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translation_local_data_source.dart';
import 'translation_remote_data_source.dart';
import '../../core/errors/app_exceptions.dart';

class TranslationHybridDataSource {
  final TranslationLocalDataSource _localDataSource;
  final TranslationRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;
  late final SharedPreferences _prefs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true;

  TranslationHybridDataSource({
    required TranslationLocalDataSource localDataSource,
    required TranslationRemoteDataSource remoteDataSource,
    required Connectivity connectivity,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _connectivity = connectivity;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _checkConnectivity();
    _listenToConnectivityChanges();
  }

  void _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _isConnected = _isDeviceConnected(connectivityResult);
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _isConnected = _isDeviceConnected(result);
    });
  }

  bool _isDeviceConnected(List<ConnectivityResult> result) {
    return !result.contains(ConnectivityResult.none);
  }

  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final cacheKey = "translation-'$sourceLang-$targetLang-$text";
    final cachedTranslation = _prefs.getString(cacheKey);
    if (cachedTranslation != null) {
      return cachedTranslation;
    }

    if (_isConnected) {
      try {
        final translatedText = await _remoteDataSource
            .translateText(
              text: text,
              sourceLang: sourceLang,
              targetLang: targetLang,
            )
            .timeout(const Duration(seconds: 10));
        await _prefs.setString(cacheKey, translatedText);
        return translatedText;
      } on TimeoutException {
        return _translateLocally(text, sourceLang, targetLang);
      } on NetworkException {
        return _translateLocally(text, sourceLang, targetLang);
      } catch (e) {
        return _translateLocally(text, sourceLang, targetLang);
      }
    } else {
      return _translateLocally(text, sourceLang, targetLang);
    }
  }

  Future<String> _translateLocally(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    final sourceModelDownloaded =
        await _localDataSource.isModelDownloaded(sourceLang);
    final targetModelDownloaded =
        await _localDataSource.isModelDownloaded(targetLang);

    if (!sourceModelDownloaded || !targetModelDownloaded) {
      final missingModels = <String>[];
      if (!sourceModelDownloaded) missingModels.add(sourceLang);
      if (!targetModelDownloaded) missingModels.add(targetLang);

      throw ApiException(
        'Language models not downloaded for offline translation. Please download models for: ${missingModels.join(', ')}. ',
      );
    }

    return await _localDataSource.translateText(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  Future<String> detectLanguage(String text) async {
    if (_isConnected) {
      try {
        return await _remoteDataSource
            .detectLanguage(text)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        return _detectLanguageLocally(text);
      }
    } else {
      return _detectLanguageLocally(text);
    }
  }

  String _detectLanguageLocally(String text) {
    final textLower = text.toLowerCase();
    if (RegExp(r'[а-яё]').hasMatch(textLower)) return 'RU';
    if (RegExp(r'[一-龯]').hasMatch(textLower)) return 'ZH';
    if (RegExp(r'[ひらがなカタカナ]').hasMatch(textLower)) return 'JA';
    if (RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]').hasMatch(textLower)) return 'KO';
    if (RegExp(r'[ا-ي]').hasMatch(textLower)) return 'AR';
    if (RegExp(r'[α-ωάέήίόύώ]').hasMatch(textLower)) return 'EL';
    if (RegExp(r'[א-ת]').hasMatch(textLower)) return 'HE';
    return 'EN';
  }

  Future<List<String>> getSupportedLanguages() async {
    return await _localDataSource.getSupportedLanguages();
  }

  Future<bool> downloadLanguageModel(String languageCode) async {
    return await _localDataSource.downloadLanguageModel(languageCode);
  }

  Future<bool> isModelDownloaded(String languageCode) async {
    return await _localDataSource.isModelDownloaded(languageCode);
  }

  Future<bool> deleteLanguageModel(String languageCode) async {
    return await _localDataSource.deleteLanguageModel(languageCode);
  }

  Future<List<String>> getDownloadedModels() async {
    return await _localDataSource.getDownloadedModels();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
