import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/error/failures.dart';

import '../models/article_model.dart';

abstract class NewsLocalDataSource {
  Future<List<ArticleModel>> getLastTopHeadlines();
  Future<void> cacheTopHeadlines(List<ArticleModel> articles);

  /// Returns cached search result for [query], or throws [CacheFailure] if none.
  Future<List<ArticleModel>> getCachedSearchResults(String query);

  /// Caches [articles] for [query]; evicts oldest queries if over [maxCachedSearchQueries].
  Future<void> cacheSearchResults(String query, List<ArticleModel> articles);
}

const String kCachedTopHeadlinesKey = 'CACHED_TOP_HEADLINES';
const String kSearchQueryOrderKey = 'SEARCH_QUERY_ORDER';
const int maxCachedSearchQueries = 10;

String _searchCacheKey(String query) =>
    'CACHED_SEARCH_${query.trim().toLowerCase()}';

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box box;

  NewsLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheTopHeadlines(List<ArticleModel> articles) async {
    final List<Map<String, dynamic>> jsonList =
        articles.map((a) => a.toJson()).toList();
    await box.put(kCachedTopHeadlinesKey, json.encode(jsonList));
  }

  @override
  Future<List<ArticleModel>> getLastTopHeadlines() async {
    final jsonString = box.get(kCachedTopHeadlinesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => ArticleModel.fromJson(j)).toList();
    } else {
      throw const CacheFailure('No cached news available');
    }
  }

  @override
  Future<void> cacheSearchResults(
      String query, List<ArticleModel> articles) async {
    final key = _searchCacheKey(query);
    final List<Map<String, dynamic>> jsonList =
        articles.map((a) => a.toJson()).toList();
    await box.put(key, json.encode(jsonList));

    final orderJson = box.get(kSearchQueryOrderKey) as String?;
    List<String> order = orderJson != null
        ? List<String>.from(json.decode(orderJson) as List)
        : [];
    order.remove(key);
    order.add(key);
    if (order.length > maxCachedSearchQueries) {
      for (final oldKey in order.take(order.length - maxCachedSearchQueries)) {
        await box.delete(oldKey);
      }
      order = order.sublist(order.length - maxCachedSearchQueries);
    }
    await box.put(kSearchQueryOrderKey, json.encode(order));
  }

  @override
  Future<List<ArticleModel>> getCachedSearchResults(String query) async {
    final key = _searchCacheKey(query);
    final jsonString = box.get(key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => ArticleModel.fromJson(j)).toList();
    } else {
      throw const CacheFailure('No cached search results');
    }
  }
}
