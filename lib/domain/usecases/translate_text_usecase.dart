import '../../core/errors/app_exceptions.dart' show AppException;
import '../repositories/translation_repository.dart' show TranslationRepository;

class TranslateTextUseCase {
  final TranslationRepository repository;

  TranslateTextUseCase({required this.repository});

  Future<String> execute({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (text.isEmpty) {
      throw AppException('Please enter text to translate');
    }

    if (sourceLang == targetLang) {
      throw AppException('Source and target languages cannot be the same');
    }

    return await repository.translateText(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }
}
