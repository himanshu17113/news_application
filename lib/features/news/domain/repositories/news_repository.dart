import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/article.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<Article>>> getTopHeadlines(int page);
  Future<Either<Failure, List<Article>>> searchNews(String query, int page);
}
