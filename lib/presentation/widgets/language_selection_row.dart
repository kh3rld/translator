import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'language_dropdown.dart';

class LanguageSelectionRow extends StatelessWidget {
  final String sourceLang;
  final String targetLang;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onTargetChanged;
  final VoidCallback onSwap;

  const LanguageSelectionRow({
    super.key,
    required this.sourceLang,
    required this.targetLang,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: _buildLanguageCard(
              title: 'From',
              icon: Icons.input,
              child: LanguageDropdown(
                value: sourceLang,
                onChanged: onSourceChanged,
                isSource: true,
              ),
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
              onPressed: () {
                HapticFeedback.lightImpact();
                onSwap();
              },
              icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildLanguageCard(
              title: 'To',
              icon: Icons.output,
              child: LanguageDropdown(
                value: targetLang,
                onChanged: onTargetChanged,
                isSource: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
          child,
        ],
      ),
    );
  }
}


