part of 'list_user_bloc.dart';

abstract class ListUserEvent extends Equatable {
  const ListUserEvent();

  @override
  List<Object> get props => [];
}

class FetchListUser extends ListUserEvent {}

class LoadMoreListUser extends ListUserEvent {
  final int page;
  final String query; // Thêm trường query

  const LoadMoreListUser(this.page, this.query); 

  @override
  List<Object> get props => [page, query]; 
}

class SearchListUser extends ListUserEvent {
  final String query;

  const SearchListUser(this.query);

  @override
  List<Object> get props => [query];
}