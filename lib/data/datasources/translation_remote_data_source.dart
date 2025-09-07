import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';

class TranslationRemoteDataSource {
  final http.Client _client;
  final String _apiKey = AppConstants.deeplApiKey;
  final String _baseUrl = 'https://api-free.deepl.com/v2';

  TranslationRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<String> translateText({
    required String text,
    required String targetLang,
    String? sourceLang,
  }) async {
    final params = {
      'auth_key': _apiKey,
      'text': text,
      'target_lang': targetLang,
      if (sourceLang != null) 'source_lang': sourceLang,
    };

    final uri = Uri.parse('$_baseUrl/translate').replace(queryParameters: params);

    try {
      final response = await _client.post(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translations'][0]['text'];
      } else {
        throw ApiException('DeepL API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw NetworkException('Failed to connect to DeepL API: $e');
    }
  }

  Future<String> detectLanguage(String text) async {
    final params = {
      'auth_key': _apiKey,
      'text': text,
    };

    final uri = Uri.parse('$_baseUrl/translate').replace(queryParameters: params);

    try {
      final response = await _client.post(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translations'][0]['detected_source_language'];
      } else {
        throw ApiException('DeepL API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw NetworkException('Failed to connect to DeepL API: $e');
    }
  }
}
