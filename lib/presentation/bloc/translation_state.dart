part of 'translation_bloc.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationSuccess extends TranslationState {
  final String translatedText;
  final String sourceLang;
  final String targetLang;

  const TranslationSuccess({
    required this.translatedText,
    this.sourceLang = '',
    this.targetLang = '',
  });

  @override
  List<Object?> get props => [translatedText, sourceLang, targetLang];
}

class TranslationError extends TranslationState {
  final String errorMessage;

  const TranslationError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class TranslationSwapped extends TranslationState {
  final String sourceLang;
  final String targetLang;

  const TranslationSwapped({
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object?> get props => [sourceLang, targetLang];
}
