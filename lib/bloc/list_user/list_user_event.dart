part of 'list_user_bloc.dart';

abstract class ListUserEvent extends Equatable {
  const ListUserEvent();

  @override
  List<Object> get props => [];
}

class FetchListUser extends ListUserEvent {}

class LoadMoreListUser extends ListUserEvent {
  final int page;

  const LoadMoreListUser(this.page);

  @override
  List<Object> get props => [page];
}

class SearchListUser extends ListUserEvent {
  final String query;

  const SearchListUser(this.query);

  @override
  List<Object> get props => [query];
}