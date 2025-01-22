part of 'list_user_request_role_bloc.dart';

abstract class ListRoleRequestEvent extends Equatable {
  const ListRoleRequestEvent();

  @override
  List<Object?> get props => [];
}

class FetchRoleRequests extends ListRoleRequestEvent {
  const FetchRoleRequests();
}

class LoadMoreRoleRequests extends ListRoleRequestEvent {
  final int page;
  final String query;

  const LoadMoreRoleRequests(this.page, this.query);

  @override
  List<Object?> get props => [query];
}

class SearchRoleRequests extends ListRoleRequestEvent {
  final String query;

  const SearchRoleRequests(this.query);

  @override
  List<Object?> get props => [query];
}

abstract class DeleteRoleRequestEvent extends Equatable {
  const DeleteRoleRequestEvent();

  @override
  List<Object?> get props => [];
}

class DeleteRoleRequest extends DeleteRoleRequestEvent {
  final String requestId; // ID của request cần xóa

  const DeleteRoleRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}