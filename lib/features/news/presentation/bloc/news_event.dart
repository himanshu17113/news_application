import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class GetTopHeadlinesEvent extends NewsEvent {
  const GetTopHeadlinesEvent();
}

class GetMoreTopHeadlinesEvent extends NewsEvent {
  const GetMoreTopHeadlinesEvent();
}

class SearchNewsEvent extends NewsEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class GetMoreSearchResultsEvent extends NewsEvent {
  const GetMoreSearchResultsEvent();
}
