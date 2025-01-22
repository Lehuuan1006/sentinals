part of 'request_delete_users_list_bloc.dart';

abstract class RequestDeleteUserEvent extends Equatable {
  const RequestDeleteUserEvent();

  @override
  List<Object> get props => [];
}

class FetchRequestDeleteUser extends RequestDeleteUserEvent {
  const FetchRequestDeleteUser();
}

class LoadMoreRequestDeleteUser extends RequestDeleteUserEvent {
  final int page;
  final String query;

  const LoadMoreRequestDeleteUser(this.page, this.query);
  @override
  List<Object> get props => [page, query]; 
}

class SearchRequestDeleteUser extends RequestDeleteUserEvent {
  final String query;

  const SearchRequestDeleteUser(this.query);

  @override
  List<Object> get props => [query];
}