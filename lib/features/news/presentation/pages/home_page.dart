import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/presentation/bloc/news_bloc.dart';
import 'package:news_app/features/news/presentation/bloc/news_event.dart';
import 'package:news_app/features/news/presentation/bloc/news_state.dart';
import 'article_detail_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

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
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NewsBloc>().add(const GetMoreTopHeadlinesEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            title: const Text('Top Headlines'),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const SearchPage()),
                  );
                },
              )
            ],
          ),
          BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              if (state is NewsLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator(radius: 16)),
                );
              } else if (state is NewsEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.news,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          state.reason == NewsEmptyReason.cacheEmpty
                              ? 'No cached data. Load when online to see headlines here.'
                              : 'No headlines available.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () {
                            context
                                .read<NewsBloc>()
                                .add(const GetTopHeadlinesEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is NewsError) {
                final isConnection = state.failure is ConnectionFailure;
                final message =
                    isConnection ? 'No internet connection.' : state.message;
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isConnection
                                ? CupertinoIcons.wifi_slash
                                : CupertinoIcons.exclamationmark_circle,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: () {
                              context
                                  .read<NewsBloc>()
                                  .add(const GetTopHeadlinesEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is NewsLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.articles.length) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CupertinoActivityIndicator()),
                        );
                      }
                      final article = state.articles[index];
                      return ArticleCard(article: article);
                    },
                    childCount: state.hasReachedMax
                        ? state.articles.length
                        : state.articles.length + 1,
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ArticleDetailPage(article: article),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage != null)
                Hero(
                  tag: article.urlToImage!,
                  child: CachedNetworkImage(
                    imageUrl: article.urlToImage!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                        height: 220,
                        color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(CupertinoIcons.photo,
                            color: Colors.grey[400])),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title ?? 'No Title',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (article.description != null)
                      Text(
                        article.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (article.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.name!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (article.publishedAt != null)
                          Text(
                            _formatDate(article.publishedAt!),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
