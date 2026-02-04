import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/config/api_key_missing_screen.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/injection/service_locator.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/get_top_headlines.dart';
import 'package:news_app/features/news/domain/usecases/search_news.dart';
import 'package:news_app/features/news/presentation/bloc/news_bloc.dart';
import 'package:news_app/features/news/presentation/bloc/news_event.dart';
import 'package:news_app/features/news/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.newsApiKey.isEmpty) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News',
      theme: ThemeData(useMaterial3: true),
      home: const ApiKeyMissingScreen(),
    ));
    return;
  }

  await init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final newsRepository = sl<NewsRepository>();
    return RepositoryProvider<NewsRepository>.value(
      value: newsRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final repo = context.read<NewsRepository>();
              return NewsBloc(
                getTopHeadlines: GetTopHeadlines(repo),
                searchNews: SearchNews(repo),
              )..add(const GetTopHeadlinesEvent());
            },
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'News',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              dynamicSchemeVariant: DynamicSchemeVariant.content,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              dynamicSchemeVariant: DynamicSchemeVariant.content,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
