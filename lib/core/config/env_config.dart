import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';

class EnvConfig {
  static bool get _loaded => dotenv.isInitialized;

  static String get apiKey {
    final key = _loaded ? dotenv.env['DEEPL_API_KEY'] : null;
    return key?.trim() ?? '';
  }

  static String get apiBaseUrl {
    final fromEnv = _loaded ? dotenv.env['DEEPL_API_BASE']?.trim() : null;
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return AppConstants.apiBaseUrl;
  }
}


