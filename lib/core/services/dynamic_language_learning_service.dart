import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'backend_api_service.dart';
import '../errors/app_exceptions.dart';

class DynamicLanguageLearningService {
  static const String _vocabularyKey = 'user_vocabulary';
  static const String _learningProgressKey = 'learning_progress';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _lastStudyDateKey = 'last_study_date';

  // Get vocabulary from backend API
  static Future<List<VocabularyWord>> getVocabulary({
    String? language,
    String? difficulty,
    String? category,
    int limit = 20,
  }) async {
    try {
      final response = await BackendApiService.getVocabulary(
        language: language,
        difficulty: difficulty,
        category: category,
        perPage: limit,
      );

      return response.map((item) => VocabularyWord.fromJson(item)).toList();
    } catch (e) {
      throw ApiException('Failed to fetch vocabulary: $e');
    }
  }

  // Get random vocabulary from backend API
  static Future<List<VocabularyWord>> getRandomVocabulary({
    String? language,
    String? difficulty,
    int count = 10,
  }) async {
    try {
      final response = await BackendApiService.getRandomVocabulary(
        language: language,
        difficulty: difficulty,
        count: count,
      );

      final vocabularyData = response['vocabulary'] as List<dynamic>;
      return vocabularyData
          .map((item) => VocabularyWord.fromJson(item))
          .toList();
    } catch (e) {
      throw ApiException('Error fetching random vocabulary: $e');
    }
  }

  // Search vocabulary from backend API
  static Future<List<VocabularyWord>> searchVocabulary({
    required String query,
    String? language,
    int limit = 20,
  }) async {
    try {
      final response = await BackendApiService.searchVocabulary(
        query: query,
        language: language,
        limit: limit,
      );

      final results = response['results'] as List<dynamic>;
      return results.map((item) => VocabularyWord.fromJson(item)).toList();
    } catch (e) {
      throw ApiException('Error searching vocabulary: $e');
    }
  }

  // Get learning tips from backend API
  static Future<List<LearningTip>> getLearningTips({
    String? language,
    String? type,
    String? difficulty,
  }) async {
    try {
      final response = await BackendApiService.getLearningTips(
        language: language,
        type: type,
        difficulty: difficulty,
      );

      final tipsData = response['tips'] as List<dynamic>;
      return tipsData.map((item) => LearningTip.fromJson(item)).toList();
    } catch (e) {
      throw ApiException('Error fetching learning tips: $e');
    }
  }

  // Get cultural insights from backend API
  static Future<List<CulturalInsight>> getCulturalInsights({
    String? language,
    String? category,
  }) async {
    try {
      final response = await BackendApiService.getCulturalInsights(
        language: language,
        category: category,
      );

      final insightsData = response['insights'] as List<dynamic>;
      return insightsData
          .map((item) => CulturalInsight.fromJson(item))
          .toList();
    } catch (e) {
      throw ApiException('Error fetching cultural insights: $e');
    }
  }

  // Get daily challenges from backend API
  static Future<List<DailyChallenge>> getDailyChallenges({
    String? language,
    String? difficulty,
    String? date,
  }) async {
    try {
      final response = await BackendApiService.getDailyChallenges(
        language: language,
        difficulty: difficulty,
        date: date,
      );

      final challengesData = response['challenges'] as List<dynamic>;
      return challengesData
          .map((item) => DailyChallenge.fromJson(item))
          .toList();
    } catch (e) {
      throw ApiException('Error fetching daily challenges: $e');
    }
  }

  // Get user progress from backend API
  static Future<UserProgress?> getUserProgress({
    String? language,
    String? period,
  }) async {
    try {
      final response = await BackendApiService.getUserProgress(
        language: language,
        period: period,
      );

      final progressData = response['progress'] as Map<String, dynamic>;
      return UserProgress.fromJson(progressData);
    } catch (e) {
      throw ApiException('Error fetching user progress: $e');
    }
  }

  // Update user progress via backend API
  static Future<bool> updateUserProgress({
    required String language,
    int? wordsLearned,
    int? translationsCompleted,
    int? studyTimeMinutes,
    List<String>? achievements,
    int? xpEarned,
  }) async {
    try {
      await BackendApiService.updateUserProgress(
        language: language,
        wordsLearned: wordsLearned,
        translationsCompleted: translationsCompleted,
        studyTimeMinutes: studyTimeMinutes,
        achievements: achievements,
        xpEarned: xpEarned,
      );
      return true;
    } catch (e) {
      throw ApiException('Error updating user progress: $e');
    }
  }

  // Get learning statistics from backend API
  static Future<LearningStats?> getLearningStats({
    String? period,
    String? language,
  }) async {
    try {
      final response = await BackendApiService.getLearningStats(
        period: period,
        language: language,
      );

      final statsData = response['stats'] as Map<String, dynamic>;
      return LearningStats.fromJson(statsData);
    } catch (e) {
      throw ApiException('Error fetching learning stats: $e');
    }
  }

  // Generate vocabulary quiz from backend data
  static Future<VocabularyQuiz> generateVocabularyQuiz({
    String? language,
    String? difficulty,
    int questionCount = 5,
  }) async {
    try {
      final vocabulary = await getRandomVocabulary(
        language: language,
        difficulty: difficulty,
        count: questionCount * 2,
      );

      if (vocabulary.isEmpty) {
        return VocabularyQuiz(questions: [], totalQuestions: 0);
      }

      final questions = <QuizQuestion>[];
      final random = Random();

      for (int i = 0; i < questionCount && i < vocabulary.length; i++) {
        final correctWord = vocabulary[i];
        final options = <String>[];

        options.add(correctWord.english);

        final otherWords =
            vocabulary.where((w) => w.id != correctWord.id).toList();
        while (options.length < 4 && options.length - 1 < otherWords.length) {
          final wrongWord = otherWords[random.nextInt(otherWords.length)];
          if (!options.contains(wrongWord.english)) {
            options.add(wrongWord.english);
          }
        }

        options.shuffle(random);

        questions.add(QuizQuestion(
          id: i.toString(),
          question: 'What is the English word for "${correctWord.english}"?',
          correctAnswer: correctWord.english,
          options: options,
          explanation:
              'This word belongs to the ${correctWord.category} category.',
        ));
      }

      return VocabularyQuiz(
          questions: questions, totalQuestions: questions.length);
    } catch (e) {
      throw ApiException('Error generating vocabulary quiz: $e');
    }
  }

  // Save user vocabulary locally (for offline access)
  static Future<void> saveUserVocabulary(
      List<VocabularyWord> vocabulary) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vocabularyJson = vocabulary.map((v) => v.toJson()).toList();
      await prefs.setString(_vocabularyKey, json.encode(vocabularyJson));
    } catch (e) {
      throw Exception('Error saving user vocabulary: $e');
    }
  }

  // Load user vocabulary from local storage
  static Future<List<VocabularyWord>> loadUserVocabulary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vocabularyString = prefs.getString(_vocabularyKey);
      if (vocabularyString != null) {
        final vocabularyJson = json.decode(vocabularyString) as List<dynamic>;
        return vocabularyJson
            .map((item) => VocabularyWord.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error loading user vocabulary: $e');
    }
  }

  // Save learning progress locally
  static Future<void> saveLearningProgress(
      Map<String, dynamic> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_learningProgressKey, json.encode(progress));
    } catch (e) {
      throw Exception('Error saving learning progress: $e');
    }
  }

  // Load learning progress from local storage
  static Future<Map<String, dynamic>> loadLearningProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressString = prefs.getString(_learningProgressKey);
      if (progressString != null) {
        return json.decode(progressString) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw Exception('Error loading learning progress: $e');
    }
  }

  // Update daily streak
  static Future<int> updateDailyStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastStudyDate = prefs.getString(_lastStudyDateKey);
      final currentStreak = prefs.getInt(_dailyStreakKey) ?? 0;

      if (lastStudyDate != today) {
        final yesterday = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0];
        final newStreak = lastStudyDate == yesterday ? currentStreak + 1 : 1;

        await prefs.setString(_lastStudyDateKey, today);
        await prefs.setInt(_dailyStreakKey, newStreak);

        return newStreak;
      }

      return currentStreak;
    } catch (e) {
      throw Exception('Error updating daily streak: $e');
    }
  }

  // Get current daily streak
  static Future<int> getDailyStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_dailyStreakKey) ?? 0;
    } catch (e) {
      throw Exception('Error getting daily streak: $e');
    }
  }
}

// Data models
class VocabularyWord {
  final String id;
  final String english;
  final String category;
  final String difficultyLevel;
  final String partOfSpeech;
  final int frequencyRank;
  final bool isCommon;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabularyWord({
    required this.id,
    required this.english,
    required this.category,
    required this.difficultyLevel,
    required this.partOfSpeech,
    required this.frequencyRank,
    required this.isCommon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] ?? '',
      english: json['english_word'] ?? '',
      category: json['category'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 'beginner',
      partOfSpeech: json['part_of_speech'] ?? '',
      frequencyRank: json['frequency_rank'] ?? 0,
      isCommon: json['is_common'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'english_word': english,
      'category': category,
      'difficulty_level': difficultyLevel,
      'part_of_speech': partOfSpeech,
      'frequency_rank': frequencyRank,
      'is_common': isCommon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LearningTip {
  final String id;
  final String languageCode;
  final String title;
  final String content;
  final String tipType;
  final String difficultyLevel;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningTip({
    required this.id,
    required this.languageCode,
    required this.title,
    required this.content,
    required this.tipType,
    required this.difficultyLevel,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningTip.fromJson(Map<String, dynamic> json) {
    return LearningTip(
      id: json['id'] ?? '',
      languageCode: json['language_code'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tipType: json['tip_type'] ?? '',
      difficultyLevel: json['difficulty_level'] ?? 'beginner',
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class CulturalInsight {
  final String id;
  final String title;
  final String content;
  final String language;
  final String category;
  final String importance;
  final DateTime createdAt;
  final DateTime updatedAt;

  CulturalInsight({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    required this.category,
    required this.importance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CulturalInsight.fromJson(Map<String, dynamic> json) {
    return CulturalInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      language: json['language'] ?? '',
      category: json['category'] ?? '',
      importance: json['importance'] ?? 'medium',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final String language;
  final String difficulty;
  final int points;
  final Map<String, dynamic> content;
  final String date;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.language,
    required this.difficulty,
    required this.points,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      language: json['language'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
      points: json['points'] ?? 0,
      content: json['content'] ?? {},
      date: json['date'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class UserProgress {
  final String userId;
  final String language;
  final int totalWordsLearned;
  final int totalTranslations;
  final int streakDays;
  final String currentLevel;
  final int xpPoints;
  final List<Map<String, dynamic>> achievements;
  final Map<String, dynamic> weeklyStats;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    required this.userId,
    required this.language,
    required this.totalWordsLearned,
    required this.totalTranslations,
    required this.streakDays,
    required this.currentLevel,
    required this.xpPoints,
    required this.achievements,
    required this.weeklyStats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['user_id'] ?? '',
      language: json['language'] ?? '',
      totalWordsLearned: json['total_words_learned'] ?? 0,
      totalTranslations: json['total_translations'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      currentLevel: json['current_level'] ?? 'beginner',
      xpPoints: json['xp_points'] ?? 0,
      achievements: List<Map<String, dynamic>>.from(json['achievements'] ?? []),
      weeklyStats: Map<String, dynamic>.from(json['weekly_stats'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class LearningStats {
  final int totalUsers;
  final int activeUsers;
  final int totalTranslations;
  final int totalWordsLearned;
  final int averageStudyTime;
  final List<Map<String, dynamic>> popularLanguages;
  final Map<String, dynamic> learningTrends;

  LearningStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalTranslations,
    required this.totalWordsLearned,
    required this.averageStudyTime,
    required this.popularLanguages,
    required this.learningTrends,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      totalTranslations: json['total_translations'] ?? 0,
      totalWordsLearned: json['total_words_learned'] ?? 0,
      averageStudyTime: json['average_study_time'] ?? 0,
      popularLanguages:
          List<Map<String, dynamic>>.from(json['popular_languages'] ?? []),
      learningTrends: Map<String, dynamic>.from(json['learning_trends'] ?? {}),
    );
  }
}

class VocabularyQuiz {
  final List<QuizQuestion> questions;
  final int totalQuestions;

  VocabularyQuiz({
    required this.questions,
    required this.totalQuestions,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
  });
}
