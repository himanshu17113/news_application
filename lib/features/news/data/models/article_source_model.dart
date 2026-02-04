import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_source_model.freezed.dart';
part 'article_source_model.g.dart';

@freezed
class ArticleSourceModel with _$ArticleSourceModel {
  const factory ArticleSourceModel({
    String? id,
    String? name,
  }) = _ArticleSourceModel;

  factory ArticleSourceModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleSourceModelFromJson(json);
}
