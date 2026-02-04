import 'package:equatable/equatable.dart';
import 'package:news_app/core/error/failures.dart';
import '../../domain/entities/article.dart';

/// Reason for [NewsEmpty]; used in bloc and UI for type-safe handling.
enum NewsEmptyReason {
  cacheEmpty,
  noResults,
}

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

/// Explicit empty state: no data to show (e.g. no results for query, or cache empty when offline).
class NewsEmpty extends NewsState {
  final NewsEmptyReason reason;

  const NewsEmpty({this.reason = NewsEmptyReason.noResults});

  @override
  List<Object?> get props => [reason];
}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasReachedMax;

  const NewsLoaded({required this.articles, this.hasReachedMax = false});

  @override
  List<Object?> get props => [articles, hasReachedMax];

  NewsLoaded copyWith({List<Article>? articles, bool? hasReachedMax}) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NewsError extends NewsState {
  final String message;
  final Failure? failure;

  const NewsError(this.message, [this.failure]);

  @override
  List<Object?> get props => [message, failure];
}
