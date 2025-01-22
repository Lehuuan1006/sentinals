part of 'list_user_request_role_bloc.dart';

abstract class ListRoleRequestState extends Equatable {
  const ListRoleRequestState();

  @override
  List<Object?> get props => [];
}

class ListRoleRequestInitial extends ListRoleRequestState {}

class ListRoleRequestLoading extends ListRoleRequestState {}

class ListRoleRequestSuccess extends ListRoleRequestState {
  final List<Map<String, dynamic>> data;
  final int page;
  final bool hasReachedMax;
  final String searchQuery;

  const ListRoleRequestSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
    this.searchQuery = '',
  });
  ListRoleRequestSuccess copyWith({
    List<Map<String, dynamic>>? data,
    int? page,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return ListRoleRequestSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [data, page, hasReachedMax, searchQuery];
}

class ListRoleRequestFailure extends ListRoleRequestState {
  final String message;

  const ListRoleRequestFailure({required this.message});

  @override
  List<Object?> get props => [message];
}



abstract class DeleteRoleRequestState extends Equatable {
  const DeleteRoleRequestState();

  @override
  List<Object?> get props => [];
}

class DeleteRoleRequestInitial extends DeleteRoleRequestState {}

class DeleteRoleRequestLoading extends DeleteRoleRequestState {}

class DeleteRoleRequestSuccess extends DeleteRoleRequestState {
  final String message;

  const DeleteRoleRequestSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteRoleRequestFailure extends DeleteRoleRequestState {
  final String message;

  const DeleteRoleRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}