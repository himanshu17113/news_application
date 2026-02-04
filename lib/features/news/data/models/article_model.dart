import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:news_app/features/news/domain/entities/article.dart';

import 'article_source_model.dart';

part 'article_model.freezed.dart';
part 'article_model.g.dart';

DateTime? _nullableDateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

@freezed
class ArticleModel with _$ArticleModel {
  const ArticleModel._();

  @JsonSerializable(explicitToJson: true)
  const factory ArticleModel({
    ArticleSourceModel? source,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? publishedAt,
    String? content,
  }) = _ArticleModel;

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);

  /// Maps this data model to the domain [Article] entity.
  Article toEntity() => Article(
        id: source?.id,
        name: source?.name,
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt,
        content: content,
      );
}
