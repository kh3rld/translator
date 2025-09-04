import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasources/translation_remote_data_source.dart';
import 'domain/repositories/translation_repository.dart';
import 'domain/repositories/translation_repository_impl.dart';
import 'domain/usecases/translate_text_usecase.dart';
import 'presentation/bloc/translation_bloc.dart';
import 'presentation/pages/translator_page.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint(
      'Warning: .env file not found. Using default configuration. Error: $e',
    );
  }
  setupDependencies();
  runApp(const TranslatorApp());
}

void setupDependencies() {
  getIt.registerSingleton<Dio>(Dio());

  getIt.registerSingleton<TranslationRemoteDataSource>(
    TranslationRemoteDataSource(dio: getIt<Dio>()),
  );

  getIt.registerSingleton<TranslationRepository>(
    TranslationRepositoryImpl(
      remoteDataSource: getIt<TranslationRemoteDataSource>(),
    ),
  );

  getIt.registerSingleton<TranslateTextUseCase>(
    TranslateTextUseCase(repository: getIt<TranslationRepository>()),
  );
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: BlocProvider(
        create: (context) => TranslationBloc(
          translateTextUseCase: getIt<TranslateTextUseCase>(),
        ),
        child: const TranslatorPage(),
      ),
    );
  }
}
