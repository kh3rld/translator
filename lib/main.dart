import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'data/datasources/translation_local_data_source.dart';
import 'data/datasources/translation_remote_data_source.dart';
import 'data/datasources/translation_hybrid_data_source.dart';
import 'core/services/local_translation_service.dart';
import 'domain/repositories/translation_repository.dart';
import 'domain/repositories/translation_repository_impl.dart';
import 'domain/usecases/translate_text_usecase.dart';
import 'presentation/bloc/translation_bloc.dart';
import 'presentation/pages/translator_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const TranslatorApp());
}

Future<void> setupDependencies() async {
  final localTranslationService = LocalTranslationService();
  await localTranslationService.initialize();
  getIt.registerSingleton<LocalTranslationService>(localTranslationService);

  getIt.registerSingleton<TranslationLocalDataSource>(
    TranslationLocalDataSource(
      localTranslationService: getIt<LocalTranslationService>(),
    ),
  );

  getIt.registerSingleton<TranslationRemoteDataSource>(
      TranslationRemoteDataSource());

  getIt.registerSingleton<TranslationHybridDataSource>(
    TranslationHybridDataSource(
      localDataSource: getIt<TranslationLocalDataSource>(),
      remoteDataSource: getIt<TranslationRemoteDataSource>(),
      connectivity: Connectivity(),
    ),
  );

  getIt.registerSingleton<TranslationRepository>(
    TranslationRepositoryImpl(
      dataSource: getIt<TranslationHybridDataSource>(),
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
