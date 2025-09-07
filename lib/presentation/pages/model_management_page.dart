import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/local_translation_service.dart';
import '../../core/services/language_service.dart';

class ModelManagementPage extends StatefulWidget {
  const ModelManagementPage({super.key});

  @override
  State<ModelManagementPage> createState() => _ModelManagementPageState();
}

class _ModelManagementPageState extends State<ModelManagementPage> {
  final LocalTranslationService _localTranslationService =
      GetIt.instance<LocalTranslationService>();
  final Map<String, bool> _downloadingModels = {};
  final Map<String, bool> _downloadedModels = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedModels();
  }

  Future<String> _getLanguageName(String languageCode) async {
    try {
      final language = await LanguageService.getLanguageByCode(languageCode);
      return language?['name'] ?? languageCode;
    } catch (e) {
      return languageCode;
    }
  }

  Future<void> _loadDownloadedModels() async {
    setState(() => _isLoading = true);

    final downloadedModels =
        await _localTranslationService.getDownloadedModels();
    final downloadedSet = downloadedModels.toSet();

    final languages = await LanguageService.getLanguages();
    for (final language in languages) {
      final languageCode = language['code'] as String;
      _downloadedModels[languageCode] = downloadedSet.contains(languageCode);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _downloadModel(String languageCode) async {
    setState(() {
      _downloadingModels[languageCode] = true;
    });

    try {
      final languageName = await _getLanguageName(languageCode);

      // Show initial progress message
      _showSnackBar(
        'Downloading $languageName model...',
        Colors.blue,
      );

      final success =
          await _localTranslationService.downloadLanguageModel(languageCode);
      if (success) {
        setState(() {
          _downloadedModels[languageCode] = true;
        });
        _showSnackBar(
          '$languageName model downloaded successfully! You can now translate offline.',
          Colors.green,
        );
      } else {
        _showSnackBar(
          'Failed to download $languageName model. Please check your internet connection.',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Error downloading model: $e',
        Colors.red,
      );
    } finally {
      setState(() {
        _downloadingModels[languageCode] = false;
      });
    }
  }

  Future<void> _deleteModel(String languageCode) async {
    final confirmed = await _showDeleteConfirmation(languageCode);
    if (!confirmed) return;

    try {
      final languageName = await _getLanguageName(languageCode);
      final success =
          await _localTranslationService.deleteLanguageModel(languageCode);
      if (success) {
        setState(() {
          _downloadedModels[languageCode] = false;
        });
        _showSnackBar(
          '$languageName model deleted',
          Colors.orange,
        );
      } else {
        _showSnackBar(
          'Failed to delete $languageName model',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Error deleting model: $e',
        Colors.red,
      );
    }
  }

  Future<bool> _showDeleteConfirmation(String languageCode) async {
    final languageName = await _getLanguageName(languageCode);
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Model'),
            content: Text(
              'Are you sure you want to delete the $languageName translation model? This will free up storage space but you won\'t be able to translate to/from this language offline.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Models'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Download language models for offline translation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Models are stored locally on your device. Download the languages you need for instant, private translations.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tip: Download English and Spanish first for the best experience',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: LanguageService.getLanguages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error loading languages'));
                          }

                          final languages = snapshot.data ?? [];

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: languages.length,
                            itemBuilder: (context, index) {
                              final language = languages[index];
                              final languageCode = language['code'] as String;
                              final languageName = language['name'] as String;
                              final isDownloaded =
                                  _downloadedModels[languageCode] ?? false;
                              final isDownloading =
                                  _downloadingModels[languageCode] ?? false;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isDownloaded
                                        ? Colors.green
                                        : Colors.grey[300],
                                    child: Icon(
                                      isDownloaded
                                          ? Icons.check
                                          : Icons.language,
                                      color: isDownloaded
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  title: Text(
                                    languageName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    isDownloaded
                                        ? 'Available offline'
                                        : 'Download for offline use',
                                    style: TextStyle(
                                      color: isDownloaded
                                          ? Colors.green[700]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  trailing: isDownloading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : IconButton(
                                          icon: Icon(
                                            isDownloaded
                                                ? Icons.delete
                                                : Icons.download,
                                            color: isDownloaded
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                          onPressed: () {
                                            if (isDownloaded) {
                                              _deleteModel(languageCode);
                                            } else {
                                              _downloadModel(languageCode);
                                            }
                                          },
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
