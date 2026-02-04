import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import '../../../../core/error/failures.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final InternetConnectionChecker connectionChecker;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines(int page) async {
    if (await connectionChecker.hasConnection) {
      try {
        final remoteNews = await remoteDataSource.getTopHeadlines(page);
        if (page == 1) {
          // Cache only the first page
          localDataSource.cacheTopHeadlines(remoteNews);
        }
        return Right(remoteNews.map((m) => m.toEntity()).toList());
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localNews = await localDataSource.getLastTopHeadlines();
        return Right(localNews.map((m) => m.toEntity()).toList());
      } on CacheFailure {
        // Offline and no cached data: root cause is no connection.
        return const Left(
            ConnectionFailure('No internet connection. Connect to load news.'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Article>>> searchNews(
      String query, int page) async {
    if (await connectionChecker.hasConnection) {
      try {
        final remoteNews = await remoteDataSource.searchNews(query, page: page);
        if (page == 1) {
          localDataSource.cacheSearchResults(query, remoteNews);
        }
        return Right(remoteNews.map((m) => m.toEntity()).toList());
      } on ServerFailure catch (e) {
        return Left(e);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      if (page == 1) {
        try {
          final cached = await localDataSource.getCachedSearchResults(query);
          return Right(cached.map((m) => m.toEntity()).toList());
        } on CacheFailure {
          // Offline and no cached data for this query: root cause is no connection.
          return const Left(ConnectionFailure(
              'No internet connection. Connect to search, or try a cached query.'));
        }
      }
      // Offline and requesting more pages: need connection.
      return const Left(ConnectionFailure(
          'No internet connection. Connect to load more results.'));
    }
  }
}
