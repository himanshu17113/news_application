import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/usecase/usecase.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';

class GetTopHeadlines implements UseCase<List<Article>, TopHeadlinesParams> {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(TopHeadlinesParams params) async {
    return await repository.getTopHeadlines(params.page);
  }
}

class TopHeadlinesParams extends Equatable {
  final int page;

  const TopHeadlinesParams({required this.page});

  @override
  List<Object> get props => [page];
}
