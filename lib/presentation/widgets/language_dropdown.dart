import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/language_service.dart';
import 'enhanced_language_dialog.dart';

/// Professional language dropdown widget with dynamic data loading
class LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final bool isSource;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isSource,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: LanguageService.getLanguages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 48,
            child: Center(child: Text('Error loading languages')),
          );
        }

        final languages = snapshot.data ?? [];
        final currentLanguage = languages.firstWhere(
          (lang) => lang['code'] == value,
          orElse: () => {'name': 'Select Language'},
        );
        final currentLanguageName =
            currentLanguage['name'] ?? 'Select Language';

        return GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            final selectedLanguage = await showDialog<String>(
              context: context,
              builder: (context) => EnhancedLanguageDialog(
                isSource: isSource,
                currentLanguage: value,
              ),
            );

            if (selectedLanguage != null) {
              onChanged(selectedLanguage);
              final selectedLang = languages.firstWhere(
                (lang) => lang['code'] == selectedLanguage,
                orElse: () => {'name': selectedLanguage},
              );
              final langName = selectedLang['name'] ?? selectedLanguage;
              final bg = isSource
                  ? Colors.blue.withValues(alpha: 0.9)
                  : Colors.purple.withValues(alpha: 0.9);
              final icon = isSource ? Icons.input : Icons.output;
              final msg = isSource
                  ? 'Source set to $langName'
                  : 'Target set to $langName';

              // Professional snackbar notification
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  content: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          msg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentLanguageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
