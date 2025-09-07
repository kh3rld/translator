import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Professional language service for dynamic language data management
class LanguageService {
  static const String _baseUrl = AppConstants.apiBaseUrl;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  static Map<String, dynamic>? _languagesCache;
  static DateTime? _lastCacheUpdate;

  /// Get all available languages from the backend
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      if (_languagesCache != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout) {
        return List<Map<String, dynamic>>.from(
            _languagesCache!['languages'] ?? []);
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${AppConstants.apiLanguagesEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> languages = json.decode(response.body);
        _languagesCache = {'languages': languages};
        _lastCacheUpdate = DateTime.now();
        return List<Map<String, dynamic>>.from(languages);
      } else {
        throw Exception('Failed to load languages: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackLanguages();
    }
  }

  /// Get language by code
  static Future<Map<String, dynamic>?> getLanguageByCode(String code) async {
    final languages = await getLanguages();
    try {
      return languages.firstWhere((lang) => lang['code'] == code);
    } catch (e) {
      return null;
    }
  }

  /// Get popular languages
  static Future<List<Map<String, dynamic>>> getPopularLanguages() async {
    final languages = await getLanguages();
    return languages.where((lang) => lang['is_popular'] == true).toList();
  }

  /// Get languages by category
  static Future<List<Map<String, dynamic>>> getLanguagesByCategory(
      String category) async {
    final languages = await getLanguages();
    return languages.where((lang) => lang['category'] == category).toList();
  }

  /// Get language categories
  static Future<List<String>> getLanguageCategories() async {
    final languages = await getLanguages();
    final categories =
        languages.map((lang) => lang['category'] as String).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Get supported language codes
  static Future<List<String>> getSupportedLanguageCodes() async {
    final languages = await getLanguages();
    return languages.map((lang) => lang['code'] as String).toList();
  }

  /// Get language flags mapping
  static Future<Map<String, String>> getLanguageFlags() async {
    final languages = await getLanguages();
    final Map<String, String> flags = {};
    for (final lang in languages) {
      flags[lang['code']] = lang['flag_emoji'] ?? '';
    }
    return flags;
  }

  /// Get language difficulty mapping
  static Future<Map<String, String>> getLanguageDifficulty() async {
    final languages = await getLanguages();
    final Map<String, String> difficulty = {};
    for (final lang in languages) {
      difficulty[lang['code']] = lang['difficulty_level'] ?? 'beginner';
    }
    return difficulty;
  }

  /// Get language facts
  static Future<Map<String, String>> getLanguageFacts() async {
    final languages = await getLanguages();
    final Map<String, String> facts = {};
    for (final lang in languages) {
      final name = lang['name'] as String;
      final nativeName = lang['native_name'] as String;
      facts[lang['code']] =
          '$name is also known as $nativeName in its native form.';
    }
    return facts;
  }

  /// Fallback language data for offline scenarios
  static List<Map<String, dynamic>> _getFallbackLanguages() {
    return [
      {
        'code': 'EN',
        'name': 'English',
        'native_name': 'English',
        'flag_emoji': 'US',
        'category': 'Popular',
        'difficulty_level': 'beginner',
        'is_popular': true,
        'is_active': true,
      },
      {
        'code': 'ES',
        'name': 'Spanish',
        'native_name': 'Español',
        'flag_emoji': 'ES',
        'category': 'Romance',
        'difficulty_level': 'beginner',
        'is_popular': true,
        'is_active': true,
      },
      {
        'code': 'FR',
        'name': 'French',
        'native_name': 'Français',
        'flag_emoji': 'FR',
        'category': 'Romance',
        'difficulty_level': 'intermediate',
        'is_popular': true,
        'is_active': true,
      },
      {
        'code': 'DE',
        'name': 'German',
        'native_name': 'Deutsch',
        'flag_emoji': 'DE',
        'category': 'Germanic',
        'difficulty_level': 'intermediate',
        'is_popular': true,
        'is_active': true,
      },
      {
        'code': 'IT',
        'name': 'Italian',
        'native_name': 'Italiano',
        'flag_emoji': 'IT',
        'category': 'Romance',
        'difficulty_level': 'beginner',
        'is_popular': true,
        'is_active': true,
      },
    ];
  }

  /// Clear cache to force refresh
  static void clearCache() {
    _languagesCache = null;
    _lastCacheUpdate = null;
  }
}
