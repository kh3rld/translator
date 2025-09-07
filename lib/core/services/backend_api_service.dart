import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class BackendApiService {
  static const String _baseUrl = AppConstants.apiBaseUrl;

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${AppConstants.apiHealthEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to check health: $e');
    }
  }

  // Get languages with retry logic and timeout
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    const maxRetries = 3;
    const timeout = Duration(seconds: 10);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl${AppConstants.apiLanguagesEndpoint}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'TranslatorApp/1.0',
          },
        ).timeout(timeout);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else if (response.statusCode >= 500 && attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
          continue;
        } else {
          throw Exception(
              'Failed to fetch languages: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception(
              'Failed to get languages after $maxRetries attempts: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    throw Exception('Failed to get languages: Max retries exceeded');
  }

  // Get language categories
  static Future<Map<String, dynamic>> getLanguageCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/languages/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch language categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get language categories: $e');
    }
  }

  // Get vocabulary
  static Future<List<Map<String, dynamic>>> getVocabulary({
    String? language,
    String? difficulty,
    String? category,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (category != null) queryParams['category'] = category;
      queryParams['page'] = page.toString();
      queryParams['per_page'] = perPage.toString();

      final uri = Uri.parse('$_baseUrl${AppConstants.apiVocabularyEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get vocabulary: $e');
    }
  }

  // Get random vocabulary
  static Future<Map<String, dynamic>> getRandomVocabulary({
    String? language,
    String? difficulty,
    int count = 10,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      queryParams['count'] = count.toString();

      final uri = Uri.parse('$_baseUrl/vocabulary/random')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch random vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get random vocabulary: $e');
    }
  }

  // Search vocabulary
  static Future<Map<String, dynamic>> searchVocabulary({
    required String query,
    String? language,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'limit': limit.toString(),
      };
      if (language != null) queryParams['language'] = language;

      final uri = Uri.parse('$_baseUrl/vocabulary/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search vocabulary: $e');
    }
  }

  // Get learning tips
  static Future<Map<String, dynamic>> getLearningTips({
    String? type,
    String? language,
    String? difficulty,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (language != null) queryParams['language'] = language;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final uri = Uri.parse('$_baseUrl${AppConstants.apiLearningTipsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch learning tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get learning tips: $e');
    }
  }

  // Get cultural insights
  static Future<Map<String, dynamic>> getCulturalInsights({
    String? language,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (category != null) queryParams['category'] = category;

      final uri =
          Uri.parse('$_baseUrl${AppConstants.apiCulturalInsightsEndpoint}')
              .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch cultural insights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get cultural insights: $e');
    }
  }

  // Get daily challenges
  static Future<Map<String, dynamic>> getDailyChallenges({
    String? language,
    String? difficulty,
    String? date,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (date != null) queryParams['date'] = date;

      final uri =
          Uri.parse('$_baseUrl${AppConstants.apiDailyChallengesEndpoint}')
              .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch daily challenges: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get daily challenges: $e');
    }
  }

  // Get user progress
  static Future<Map<String, dynamic>> getUserProgress({
    String? language,
    String? period,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (period != null) queryParams['period'] = period;

      final uri = Uri.parse('$_baseUrl${AppConstants.apiUserProgressEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch user progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  // Update user progress
  static Future<Map<String, dynamic>> updateUserProgress({
    required String language,
    int? wordsLearned,
    int? translationsCompleted,
    int? studyTimeMinutes,
    List<String>? achievements,
    int? xpEarned,
  }) async {
    try {
      final body = <String, dynamic>{
        'language': language,
      };
      if (wordsLearned != null) {
        body['words_learned'] = wordsLearned;
      }
      if (translationsCompleted != null) {
        body['translations_completed'] = translationsCompleted;
      }
      if (studyTimeMinutes != null) {
        body['study_time_minutes'] = studyTimeMinutes;
      }
      if (achievements != null) body['achievements'] = achievements;
      if (xpEarned != null) body['xp_earned'] = xpEarned;

      final response = await http.post(
        Uri.parse('$_baseUrl${AppConstants.apiUserProgressEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to update user progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update user progress: $e');
    }
  }

  // Get learning stats
  static Future<Map<String, dynamic>> getLearningStats({
    String? period,
    String? language,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (language != null) queryParams['language'] = language;

      final uri = Uri.parse(
              '$_baseUrl${AppConstants.apiAnalyticsEndpoint}/learning-stats')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch learning stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get learning stats: $e');
    }
  }

  // Get popular languages
  static Future<Map<String, dynamic>> getPopularLanguages() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl${AppConstants.apiAnalyticsEndpoint}/popular-languages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to fetch popular languages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get popular languages: $e');
    }
  }
}
