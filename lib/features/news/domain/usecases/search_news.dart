import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class SearchNews implements UseCase<List<Article>, SearchNewsParams> {
  final NewsRepository repository;

  SearchNews(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(SearchNewsParams params) async {
    return await repository.searchNews(params.query, params.page);
  }
}

class SearchNewsParams extends Equatable {
  final String query;
  final int page;

  const SearchNewsParams({required this.query, this.page = 1});

  @override
  List<Object> get props => [query, page];
}
