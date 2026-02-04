import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../features/news/data/datasources/news_local_data_source.dart';
import '../../features/news/data/datasources/news_remote_data_source.dart';
import '../../features/news/data/repositories/news_repository_impl.dart';
import '../../features/news/domain/repositories/news_repository.dart';

/// Global service locator. Use for:
/// - Non-widget access (e.g. deep links, background refresh, platform callbacks)
/// - Tests: call [initForTesting] then [sl]<NewsRepository>()
final sl = GetIt.instance;

/// Registers production dependencies. Call from [main] before [runApp].
Future<void> init() async {
  await Hive.initFlutter();
  final box = await Hive.openBox('newsBox');
  sl.registerSingleton<Box>(box);

  sl.registerLazySingleton<Dio>(() => createNewsDio());
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(box: sl<Box>()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectionChecker: sl(),
    ),
  );
}

/// Registers a [NewsRepository] for tests. Call before pumping [MyApp].
/// Resets the locator so each test starts clean.
Future<void> initForTesting(NewsRepository newsRepository) async {
  await sl.reset();
  sl.registerSingleton<NewsRepository>(newsRepository);
}
