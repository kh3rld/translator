import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../core/services/dynamic_language_learning_service.dart';
import '../../core/services/enhanced_tts_service.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/services/language_service.dart';

class LanguageLearningPage extends StatefulWidget {
  const LanguageLearningPage({super.key});

  @override
  State<LanguageLearningPage> createState() => _LanguageLearningPageState();
}

class _LanguageLearningPageState extends State<LanguageLearningPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _gameController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'ES';
  String _selectedDifficulty = 'Beginner';
  int _currentScore = 0;
  int _currentStreak = 0;
  bool _isGameActive = false;
  VocabularyWord? _currentWord;
  String? _userAnswer;
  bool _showAnswer = false;
  List<String> _shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _gameController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadLearningStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gameController.dispose();
    super.dispose();
  }

  Future<String> _getLanguageName(String languageCode) async {
    try {
      final language = await LanguageService.getLanguageByCode(languageCode);
      return language?['name'] ?? languageCode;
    } catch (e) {
      return languageCode;
    }
  }

  Future<void> _loadLearningStats() async {
    final stats = await DynamicLanguageLearningService.getLearningStats();
    final streak = await DynamicLanguageLearningService.getDailyStreak();
    setState(() {
      _currentScore = stats?.totalWordsLearned ?? 0;
      _currentStreak = streak;
    });
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _currentScore = 0;
      _currentStreak = 0;
    });
    _generateNewQuestion();
  }

  Future<void> _generateNewQuestion() async {
    final words = await DynamicLanguageLearningService.getRandomVocabulary(
      language: _selectedLanguage,
      difficulty: _selectedDifficulty.toLowerCase(),
      count: 1,
    );
    final word = words.isNotEmpty ? words.first : null;
    if (word == null) return;

    final correctAnswer = word.english; // Use English word as the answer
    final wrongAnswers = await _generateWrongAnswers(correctAnswer);

    setState(() {
      _currentWord = word;
      _shuffledOptions = [correctAnswer, ...wrongAnswers]..shuffle();
      _userAnswer = null;
      _showAnswer = false;
    });

    _gameController.forward();
  }

  Future<List<String>> _generateWrongAnswers(String correctAnswer) async {
    final allWords = await DynamicLanguageLearningService.getVocabulary(
      language: _selectedLanguage,
      difficulty: _selectedDifficulty.toLowerCase(),
    );
    final wrongAnswers = <String>[];

    while (
        wrongAnswers.length < 3 && wrongAnswers.length < allWords.length - 1) {
      final randomWord = allWords[Random().nextInt(allWords.length)];
      final translation = randomWord.english; // Use English word
      if (translation != correctAnswer && !wrongAnswers.contains(translation)) {
        wrongAnswers.add(translation);
      }
    }

    return wrongAnswers;
  }

  void _selectAnswer(String answer) {
    if (_showAnswer) return;

    setState(() {
      _userAnswer = answer;
      _showAnswer = true;
    });

    HapticFeedback.mediumImpact();

    final isCorrect = answer == _currentWord!.english;
    if (isCorrect) {
      _currentScore += 10;
      _currentStreak++;
      _showCorrectFeedback();
    } else {
      _currentStreak = 0;
      _showIncorrectFeedback();
    }

    // Auto-advance after showing result
    Future.delayed(const Duration(seconds: 2), () {
      if (_isGameActive) {
        _generateNewQuestion();
      }
    });
  }

  void _showCorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Correct! +10 points! Streak: $_currentStreak'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showIncorrectFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Text('Incorrect! The answer was: ${_currentWord!.english}'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.indigo.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _isGameActive
                        ? _buildGameContent()
                        : _buildLearningContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language Learning',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Master new languages with fun games!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (_isGameActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Score: $_currentScore',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Streak: $_currentStreak',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearningContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildLanguageSelector(),
          const SizedBox(height: 20),
          _buildDifficultySelector(),
          const SizedBox(height: 20),
          _buildLearningStats(),
          const SizedBox(height: 20),
          _buildLearningTips(),
          const SizedBox(height: 20),
          _buildStartGameButton(),
          const SizedBox(height: 20),
          _buildVocabularyBuilder(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Language to Learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: LanguageService.getLanguages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading languages'));
              }

              final languages = snapshot.data ?? [];
              final popularLanguages = languages
                  .where((lang) => lang['is_popular'] == true)
                  .take(8)
                  .toList();

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: popularLanguages.map((langData) {
                  final lang = langData['code'] as String;
                  final isSelected = _selectedLanguage == lang;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade600
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            langData['flag_emoji'] ?? '🌐',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            langData['name'] ?? lang,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children:
                ['Beginner', 'Intermediate', 'Advanced'].map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty;
              Color color;
              switch (difficulty) {
                case 'Beginner':
                  color = Colors.green;
                  break;
                case 'Intermediate':
                  color = Colors.orange;
                  break;
                case 'Advanced':
                  color = Colors.red;
                  break;
                default:
                  color = Colors.grey;
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          difficulty,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Words Learned',
                  '$_currentScore',
                  Icons.book,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Daily Streak',
                  '$_currentStreak',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTips() {
    return FutureBuilder<List<LearningTip>>(
      future: DynamicLanguageLearningService.getLearningTips(
        language: _selectedLanguage,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ErrorHandlerService.buildLoadingWidget(
            message: 'Loading learning tips...',
          );
        }

        if (snapshot.hasError) {
          return ErrorHandlerService.buildErrorWidget(
            ErrorHandlerService.getErrorMessage(snapshot.error),
            onRetry: () {
              setState(() {}); // Trigger rebuild
            },
          );
        }

        final tips = snapshot.data ?? [];

        if (tips.isEmpty) {
          return ErrorHandlerService.buildEmptyWidget(
            message: 'No learning tips available for $_selectedLanguage',
            icon: Icons.lightbulb_outline,
            action: ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 15),
              ...tips
                  .map((tip) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tip.content,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartGameButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Start Learning Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyBuilder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vocabulary Builder',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Build your personal vocabulary collection by saving words you learn!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to vocabulary builder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vocabulary Builder coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text('Manage Vocabulary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (_currentWord == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGameQuestion(),
          const SizedBox(height: 30),
          _buildAnswerOptions(),
          const SizedBox(height: 30),
          _buildGameControls(),
        ],
      ),
    );
  }

  Widget _buildGameQuestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          FutureBuilder<String>(
            future: _getLanguageName(_selectedLanguage),
            builder: (context, snapshot) {
              final languageName = snapshot.data ?? _selectedLanguage;
              return Text(
                'What is the $languageName translation for:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            _currentWord!.english,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _currentWord!.category,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Column(
      children: _shuffledOptions.map((option) {
        final isSelected = _userAnswer == option;
        final isCorrect = option == _currentWord!.english;
        final showCorrect = _showAnswer && isCorrect;
        final showIncorrect = _showAnswer && isSelected && !isCorrect;

        Color backgroundColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = Colors.black87;

        if (showCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green.shade400;
          textColor = Colors.green.shade700;
        } else if (showIncorrect) {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red.shade400;
          textColor = Colors.red.shade700;
        } else if (isSelected) {
          backgroundColor = Colors.blue.shade100;
          borderColor = Colors.blue.shade400;
          textColor = Colors.blue.shade700;
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 15),
          child: ElevatedButton(
            onPressed: () => _selectAnswer(option),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: borderColor, width: 2),
              ),
            ),
            child: Row(
              children: [
                if (showCorrect)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (showIncorrect) const Icon(Icons.cancel, color: Colors.red),
                if (!showCorrect && !showIncorrect)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2),
                    ),
                  ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              EnhancedTTSService.speakText(
                text: _currentWord!.english,
                languageCode: 'EN',
              );
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Listen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isGameActive = false;
              });
            },
            icon: const Icon(Icons.stop),
            label: const Text('End Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
