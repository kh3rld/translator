import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/clipboard_service.dart';
import '../../core/services/text_to_speech_service.dart';
import '../../core/services/share_service.dart';
import '../bloc/translation_bloc.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/language_selection_row.dart';
import '../widgets/source_text_input.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage>
    with TickerProviderStateMixin {
  final TextEditingController _sourceTextController = TextEditingController();
  String _sourceLang = 'auto';
  String _targetLang = 'EN';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _sourceTextController.dispose();
    super.dispose();
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
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.indigo.shade100,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          LanguageSelectionRow(
                            sourceLang: _sourceLang,
                            targetLang: _targetLang,
                            onSourceChanged: (val) {
                              if (val != null) {
                                setState(() => _sourceLang = val);
                              }
                            },
                            onTargetChanged: (val) {
                              if (val != null) {
                                setState(() => _targetLang = val);
                              }
                            },
                            onSwap: _swapLanguages,
                          ),

                          const SizedBox(height: 30),

                          SourceTextInput(controller: _sourceTextController),

                          const SizedBox(height: 25),

                          _buildTranslateButton(),

                          const SizedBox(height: 25),

                          _buildResultArea(),

                          const SizedBox(height: 20),

                          _buildFeaturesSection(),

                          const SizedBox(height: 20),

                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
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
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade400.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.translate, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Smart Translation',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showInfoDialog(context);
            },
            icon: Icon(Icons.info_outline, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Legacy (unused): kept temporarily for reference during refactor
  // ignore: unused_element
  Widget _buildLanguageSelectionCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLanguageCard(
                  title: 'From',
                  language: _sourceLang,
                  onChanged: (value) {
                    setState(() {
                      _sourceLang = value!;
                    });
                  },
                  isSource: true,
                  icon: Icons.input,
                  color: Colors.blue.shade100,
                  gradient: [Colors.blue.shade50, Colors.blue.shade100],
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade400.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _swapLanguages,
                  icon: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildLanguageCard(
                  title: 'To',
                  language: _targetLang,
                  onChanged: (value) {
                    setState(() {
                      _targetLang = value!;
                    });
                  },
                  isSource: false,
                  icon: Icons.output,
                  color: Colors.purple.shade100,
                  gradient: [Colors.purple.shade50, Colors.purple.shade100],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String language,
    required ValueChanged<String?> onChanged,
    required bool isSource,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LanguageDropdown(
            value: language,
            onChanged: onChanged,
            isSource: isSource,
          ),
        ],
      ),
    );
  }

  // Legacy (unused): kept temporarily for reference during refactor
  // ignore: unused_element
  Widget _buildSourceTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Enter text to translate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
              controller: _sourceTextController,
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Type or paste your text here...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade600,
            Colors.indigo.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade400.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _translateText,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: const Icon(Icons.translate, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 15),
            Text(
              'Translate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, state) {
        if (state is TranslationLoading) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Translating...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please wait while we process your text',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is TranslationSuccess) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Translation Result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200, width: 1),
                  ),
                  child: Text(
                    state.translatedText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onTap: () {
                        ClipboardService.copyToClipboard(
                          state.translatedText,
                          context,
                        );
                      },
                      color: Colors.blue.shade600,
                    ),
                    _buildActionButton(
                      icon: Icons.volume_up,
                      label: 'Listen',
                      onTap: () {
                        TextToSpeechService.speak(
                          state.translatedText,
                          state.targetLang.isNotEmpty
                              ? state.targetLang
                              : _targetLang,
                        );
                      },
                      color: Colors.green.shade600,
                    ),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        ShareService.shareTranslation(
                          originalText: _sourceTextController.text,
                          translatedText: state.translatedText,
                          sourceLang: _sourceLang,
                          targetLang: _targetLang,
                        );
                      },
                      color: Colors.purple.shade600,
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is TranslationError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    state.errorMessage,
                    style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.auto_awesome,
                  title: 'Auto Detect',
                  subtitle: 'Smart language detection',
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.history,
                  title: 'History',
                  subtitle: 'Save translations',
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  subtitle: 'Bookmark translations',
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.offline_pin,
                  title: 'Offline',
                  subtitle: 'Work without internet',
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.clear,
                label: 'Clear',
                onTap: () {
                  _sourceTextController.clear();
                  context.read<TranslationBloc>().add(
                    const TranslateText(
                      text: '',
                      sourceLang: 'auto',
                      targetLang: 'EN',
                    ),
                  );
                },
                color: Colors.grey.shade600,
              ),
              _buildQuickActionButton(
                icon: Icons.refresh,
                label: 'Reset',
                onTap: () {
                  setState(() {
                    _sourceLang = 'auto';
                    _targetLang = 'EN';
                  });
                },
                color: Colors.blue.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              const Text('About Translator'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: ${AppConstants.appVersion}'),
              const SizedBox(height: 10),
              const Text(
                'This app uses the free MyMemory Translation API to provide accurate translations in 40+ different languages.',
              ),
              const SizedBox(height: 10),
              const Text('Features include:'),
              const Text('• Auto language detection'),
              const Text('• Copy, listen, and share translations'),
              const Text('• Modern, intuitive interface'),
              const SizedBox(height: 15),
              const Text('Developed by Khalid Husein'),
              const SizedBox(height: 5),
              const Text("Email: kherld.hussein@gmail.com"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _translateText() {
    final text = _sourceTextController.text.trim();
    if (text.isNotEmpty) {
      context.read<TranslationBloc>().add(
        TranslateText(
          text: text,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
        ),
      );
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });

    context.read<TranslationBloc>().add(SwapLanguages());
  }
}
