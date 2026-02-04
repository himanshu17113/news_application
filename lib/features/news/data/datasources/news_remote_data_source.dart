import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app/core/config/app_config.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/data/models/article_model.dart';

/// Creates a [Dio] instance configured for the News API: timeouts,
/// logging (debug only), and retries on connection errors and 5xx.
Dio createNewsDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      final opts = error.requestOptions;
      final retryCount = (opts.extra['retryCount'] as int?) ?? 0;
      const maxRetries = 2;

      final shouldRetry = retryCount < maxRetries &&
          (_isRetryableDioException(error) ||
              _isRetryableStatus(error.response?.statusCode));

      if (shouldRetry) {
        opts.extra['retryCount'] = retryCount + 1;
        await Future<void>.delayed(
            Duration(milliseconds: 500 * (retryCount + 1)));
        try {
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(error);
        }
      }
      return handler.next(error);
    },
  ));

  return dio;
}

bool _isRetryableDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return true;
    default:
      return false;
  }
}

bool _isRetryableStatus(int? status) {
  if (status == null) return false;
  return status >= 500 && status < 600;
}

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines(int page);
  Future<List<ArticleModel>> searchNews(String query, {int page = 1});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ArticleModel>> getTopHeadlines(int page) async {
    return _request(
      '/top-headlines',
      queryParameters: {
        'country': 'us',
        'apiKey': AppConfig.newsApiKey,
        'page': page,
        'pageSize': 20,
      },
      errorContext: 'Failed to load top headlines',
    );
  }

  @override
  Future<List<ArticleModel>> searchNews(String query, {int page = 1}) async {
    return _request(
      '/everything',
      queryParameters: {
        'q': query,
        'apiKey': AppConfig.newsApiKey,
        'sortBy': 'publishedAt',
        'page': page,
        'pageSize': 20,
      },
      errorContext: 'Failed to search news',
    );
  }

  Future<List<ArticleModel>> _request(
    String path, {
    required Map<String, dynamic> queryParameters,
    required String errorContext,
  }) async {
    try {
      final response =
          await dio.get<dynamic>(path, queryParameters: queryParameters);

      if (response.statusCode != 200) {
        throw _failureForStatus(response.statusCode, errorContext);
      }

      final list = _parseArticlesFromResponse(response.data);
      return list;
    } on Failure {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e, errorContext);
    } catch (e, stackTrace) {
      developer.log('News API unexpected error',
          name: 'NewsRemoteDataSource', error: e, stackTrace: stackTrace);
      throw const ServerFailure('Something went wrong. Please try again.');
    }
  }

  Failure _failureForStatus(int? status, String context) {
    switch (status) {
      case 401:
        return const ServerFailure('Invalid or missing API key.');
      case 429:
        return const ServerFailure(
            'Too many requests. Please try again later.');
      case 403:
        return const ServerFailure('Access forbidden.');
      default:
        return ServerFailure('$context Please try again.');
    }
  }

  Failure _handleDioException(DioException e, String context) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
          'No connection. Check your network and try again.');
    }

    final status = e.response?.statusCode;
    if (status != null) {
      return _failureForStatus(status, context);
    }

    developer.log('News API request error',
        name: 'NewsRemoteDataSource', error: e);
    return const ServerFailure('Something went wrong. Please try again.');
  }

  /// Parses [data] (response body). Returns a list of [ArticleModel], or empty
  /// if [data] is null, not a map, or [data]['articles'] is missing/not a list.
  /// Skips entries that are not maps or that fail to parse.
  List<ArticleModel> _parseArticlesFromResponse(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) {
      return [];
    }

    final articlesJson = data['articles'];
    if (articlesJson == null || articlesJson is! List<dynamic>) {
      return [];
    }

    final result = <ArticleModel>[];
    for (final item in articlesJson) {
      if (item is! Map<String, dynamic>) continue;
      final rawTitle = item['title'];
      if (rawTitle == null || rawTitle == '[Removed]') continue;
      try {
        result.add(ArticleModel.fromJson(item));
      } catch (_) {
        // Skip malformed article entry
        continue;
      }
    }
    return result;
  }
}
