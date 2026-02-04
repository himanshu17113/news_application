import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/get_top_headlines.dart';
import 'package:news_app/features/news/domain/usecases/search_news.dart';
import 'package:news_app/features/news/presentation/bloc/news_bloc.dart';
import 'package:news_app/features/news/presentation/bloc/news_event.dart';
import 'package:news_app/features/news/presentation/bloc/news_state.dart';
import 'package:news_app/features/news/presentation/pages/home_page.dart'; // For ArticleCard

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<NewsBloc>().add(const GetMoreSearchResultsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = context.read<NewsRepository>();
        return NewsBloc(
          getTopHeadlines: GetTopHeadlines(repo),
          searchNews: SearchNews(repo),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: CupertinoSearchTextField(
            controller: _controller,
            placeholder: 'Search news...',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            placeholderStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                // Handled via action button or we can look up context here if needed
                // But since the provider is lower down, we might need a distinct logic or just rely on the button
              }
            },
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(CupertinoIcons.search),
                onPressed: () {
                  final query = _controller.text;
                  if (query.isNotEmpty) {
                    context.read<NewsBloc>().add(SearchNewsEvent(query));
                    FocusScope.of(context).unfocus();
                  }
                },
              );
            })
          ],
        ),
        body: BlocBuilder<NewsBloc, NewsState>(
          builder: (context, state) {
            if (state is NewsInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.search,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Search for topics...',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (state is NewsLoading) {
              return const Center(
                  child: CupertinoActivityIndicator(radius: 16));
            } else if (state is NewsError) {
              final isConnection = state.failure is ConnectionFailure;
              final message =
                  isConnection ? 'No internet connection.' : state.message;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isConnection
                            ? CupertinoIcons.wifi_slash
                            : CupertinoIcons.exclamationmark_circle,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(message, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            } else if (state is NewsEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.search,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      state.reason == NewsEmptyReason.cacheEmpty
                          ? 'No cached data for this search.'
                          : 'No results found.',
                    ),
                  ],
                ),
              );
            } else if (state is NewsLoaded) {
              final itemCount = state.hasReachedMax
                  ? state.articles.length
                  : state.articles.length + 1;
              return ListView.builder(
                controller: _scrollController,
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index >= state.articles.length) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }
                  return ArticleCard(article: state.articles[index]);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
