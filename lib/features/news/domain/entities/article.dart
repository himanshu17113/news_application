import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String? id;
  final String? name; // Source name
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;

  const Article({
    this.id,
    this.name,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        author,
        title,
        description,
        url,
        urlToImage,
        publishedAt,
        content,
      ];
}
