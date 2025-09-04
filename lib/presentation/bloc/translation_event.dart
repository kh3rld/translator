part of 'translation_bloc.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class TranslateText extends TranslationEvent {
  final String text;
  final String sourceLang;
  final String targetLang;

  const TranslateText({
    required this.text,
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object?> get props => [text, sourceLang, targetLang];
}

class SwapLanguages extends TranslationEvent {
  const SwapLanguages();
}

class ChangeSourceLanguage extends TranslationEvent {
  final String language;

  const ChangeSourceLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class ChangeTargetLanguage extends TranslationEvent {
  final String language;

  const ChangeTargetLanguage(this.language);

  @override
  List<Object?> get props => [language];
}
