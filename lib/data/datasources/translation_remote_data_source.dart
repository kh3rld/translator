import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/env_config.dart';
import '../../core/errors/app_exceptions.dart'
    show NetworkException, ApiException;

class TranslationRemoteDataSource {
  final Dio dio;

  TranslationRemoteDataSource({required this.dio});

  Future<String> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final response = await dio.post(
        '${EnvConfig.apiBaseUrl}${AppConstants.apiTranslateEndpoint}',
        data: {
          'text': text,
          'source_lang': sourceLang == 'auto' ? '' : sourceLang,
          'target_lang': targetLang,
        },
        options: Options(
          headers: {
            'Authorization': 'DeepL-Auth-Key ${EnvConfig.apiKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map &&
            data['translations'] is List &&
            (data['translations'] as List).isNotEmpty) {
          return data['translations'][0]['text'] ?? 'Translation not available';
        } else {
          throw ApiException(
            'No translation data received',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          'Translation failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorMessage =
            e.response!.data?['message'] ?? 'Translation failed';

        if (statusCode == 403) {
          throw ApiException(
            'API key invalid or quota exceeded',
            statusCode: statusCode,
          );
        } else if (statusCode == 429) {
          throw ApiException('Rate limit exceeded', statusCode: statusCode);
        } else {
          throw ApiException(errorMessage, statusCode: statusCode);
        }
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      // Normalize dotenv not initialized case and other non-Dio failures
      final message = e.toString().contains('NotInitializedError')
          ? 'Environment not loaded. Please restart the app.'
          : 'Unexpected error: $e';
      throw ApiException(message);
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    try {
      final response = await dio.get(
        '${EnvConfig.apiBaseUrl}${AppConstants.apiLanguagesEndpoint}',
        options: Options(
          headers: {'Authorization': 'DeepL-Auth-Key ${EnvConfig.apiKey}'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((lang) => lang['language'] as String).toList();
        } else {
          return AppConstants.supportedLanguages.keys.toList();
        }
      } else {
        return AppConstants.supportedLanguages.keys.toList();
      }
    } catch (e) {
      return AppConstants.supportedLanguages.keys.toList();
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final response = await dio.post(
        '${EnvConfig.apiBaseUrl}${AppConstants.apiDetectEndpoint}',
        data: {'text': text},
        options: Options(
          headers: {
            'Authorization': 'DeepL-Auth-Key ${EnvConfig.apiKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['detections'] != null && data['detections'].isNotEmpty) {
          return data['detections'][0][0]['language'] ?? 'EN';
        } else {
          return 'EN';
        }
      } else {
        return 'EN';
      }
    } catch (e) {
      return 'EN';
    }
  }
}