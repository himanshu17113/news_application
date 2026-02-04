import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/injection/service_locator.dart';
import 'package:news_app/features/news/domain/entities/article.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/main.dart';

/// Fake [NewsRepository] for widget tests. Returns empty results so the app
/// can be pumped without Hive/Dio or network.
class FakeNewsRepository implements NewsRepository {
  @override
  Future<Either<Failure, List<Article>>> getTopHeadlines(int page) =>
      Future.value(const Right([]));

  @override
  Future<Either<Failure, List<Article>>> searchNews(String query, int page) =>
      Future.value(const Right([]));
}

void main() {
  testWidgets('App smoke test: HomePage shows Top Headlines',
      (WidgetTester tester) async {
    await initForTesting(FakeNewsRepository());
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Top Headlines'), findsWidgets);
  });
}
