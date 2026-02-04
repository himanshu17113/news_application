import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_top_headlines.dart';
import '../../domain/usecases/search_news.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;
  final SearchNews searchNews;
  int page = 1;
  bool isFetching = false;
  String searchQuery = '';
  int searchPage = 1;
  static const int _pageSize = 20;

  NewsBloc({
    required this.getTopHeadlines,
    required this.searchNews,
  }) : super(NewsInitial()) {
    on<GetTopHeadlinesEvent>(_onGetTopHeadlines);
    on<GetMoreTopHeadlinesEvent>(_onGetMoreTopHeadlines);
    on<SearchNewsEvent>(_onSearchNews);
    on<GetMoreSearchResultsEvent>(_onGetMoreSearchResults);
  }

  void _handleInitialResult(
    Emitter<NewsState> emit,
    Either<Failure, List<Article>> result,
    bool Function(List<Article>) computeHasReachedMax,
  ) {
    result.fold(
      (failure) {
        if (failure is ConnectionFailure) {
          emit(NewsError(failure.message, failure));
        } else if (failure is CacheFailure) {
          emit(const NewsEmpty(reason: NewsEmptyReason.cacheEmpty));
        } else {
          emit(NewsError(failure.message, failure));
        }
      },
      (articles) {
        if (articles.isEmpty) {
          emit(const NewsEmpty(reason: NewsEmptyReason.noResults));
        } else {
          emit(NewsLoaded(
            articles: articles,
            hasReachedMax: computeHasReachedMax(articles),
          ));
        }
      },
    );
  }

  void _handleLoadMoreResult(
    Emitter<NewsState> emit,
    Either<Failure, List<Article>> result,
    NewsLoaded currentState,
    void Function() clearFetching,
    bool Function(List<Article>) computeHasReachedMax,
  ) {
    result.fold(
      (failure) {
        clearFetching();
        emit(NewsError(failure.message, failure));
      },
      (articles) {
        clearFetching();
        if (articles.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(currentState.copyWith(
            articles: currentState.articles + articles,
            hasReachedMax: computeHasReachedMax(articles),
          ));
        }
      },
    );
  }

  Future<void> _onGetTopHeadlines(
    GetTopHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    page = 1;
    final result = await getTopHeadlines(TopHeadlinesParams(page: page));
    _handleInitialResult(
        emit, result, (articles) => articles.length < _pageSize);
  }

  Future<void> _onGetMoreTopHeadlines(
    GetMoreTopHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    if (state is NewsLoaded &&
        !(state as NewsLoaded).hasReachedMax &&
        !isFetching) {
      isFetching = true;
      final currentState = state as NewsLoaded;
      page++;
      final result = await getTopHeadlines(TopHeadlinesParams(page: page));
      _handleLoadMoreResult(
        emit,
        result,
        currentState,
        () => isFetching = false,
        (articles) => articles.length < _pageSize,
      );
    }
  }

  Future<void> _onSearchNews(
    SearchNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    searchQuery = event.query;
    searchPage = 1;
    final result = await searchNews(
        SearchNewsParams(query: searchQuery, page: searchPage));
    _handleInitialResult(
      emit,
      result,
      (articles) => articles.length < _pageSize,
    );
  }

  Future<void> _onGetMoreSearchResults(
    GetMoreSearchResultsEvent event,
    Emitter<NewsState> emit,
  ) async {
    if (searchQuery.isEmpty) return;
    if (state is! NewsLoaded ||
        (state as NewsLoaded).hasReachedMax ||
        isFetching) {
      return;
    }
    isFetching = true;
    final currentState = state as NewsLoaded;
    searchPage++;
    final result = await searchNews(
        SearchNewsParams(query: searchQuery, page: searchPage));
    _handleLoadMoreResult(
      emit,
      result,
      currentState,
      () => isFetching = false,
      (articles) => articles.length < _pageSize,
    );
  }
}
