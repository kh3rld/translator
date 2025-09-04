import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../domain/usecases/translate_text_usecase.dart';

part 'translation_event.dart';
part 'translation_state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslateTextUseCase translateTextUseCase;

  TranslationBloc({required this.translateTextUseCase})
    : super(TranslationInitial()) {
    on<TranslateText>(_onTranslateText);
    on<SwapLanguages>(_onSwapLanguages);
    on<ChangeSourceLanguage>(_onChangeSourceLanguage);
    on<ChangeTargetLanguage>(_onChangeTargetLanguage);
  }

  void _onTranslateText(
    TranslateText event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translatedText = await translateTextUseCase.execute(
        text: event.text,
        sourceLang: event.sourceLang,
        targetLang: event.targetLang,
      );

      emit(TranslationSuccess(translatedText: translatedText));
    } catch (e) {
      emit(
        TranslationError(
          errorMessage: e is AppException
              ? e.message
              : 'An unexpected error occurred',
        ),
      );
    }
  }

  void _onSwapLanguages(SwapLanguages event, Emitter<TranslationState> emit) {
    if (state is TranslationSuccess) {
      final currentState = state as TranslationSuccess;
      emit(
        TranslationSwapped(
          sourceLang: currentState.targetLang,
          targetLang: currentState.sourceLang,
        ),
      );
    }
  }

  void _onChangeSourceLanguage(
    ChangeSourceLanguage event,
    Emitter<TranslationState> emit,
  ) {
    if (state is TranslationSuccess) {
      final currentState = state as TranslationSuccess;
      emit(
        TranslationSuccess(
          translatedText: currentState.translatedText,
          sourceLang: event.language,
          targetLang: currentState.targetLang,
        ),
      );
    } else if (state is TranslationSwapped) {
      final currentState = state as TranslationSwapped;
      emit(
        TranslationSwapped(
          sourceLang: event.language,
          targetLang: currentState.targetLang,
        ),
      );
    }
  }

  void _onChangeTargetLanguage(
    ChangeTargetLanguage event,
    Emitter<TranslationState> emit,
  ) {
    if (state is TranslationSuccess) {
      final currentState = state as TranslationSuccess;
      emit(
        TranslationSuccess(
          translatedText: currentState.translatedText,
          sourceLang: currentState.sourceLang,
          targetLang: event.language,
        ),
      );
    } else if (state is TranslationSwapped) {
      final currentState = state as TranslationSwapped;
      emit(
        TranslationSwapped(
          sourceLang: currentState.sourceLang,
          targetLang: event.language,
        ),
      );
    }
  }
}
