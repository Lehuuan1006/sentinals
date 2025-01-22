part of 'request_delete_users_list_bloc.dart';


abstract class RequestDeleteUserListState extends Equatable {
  const RequestDeleteUserListState();

  @override
  List<Object> get props => [];
}

class RequestDeleteUserListStateInitial extends RequestDeleteUserListState {}

class RequestDeleteUserListStateLoading extends RequestDeleteUserListState {}

class RequestDeleteUserListStateSuccess extends RequestDeleteUserListState {
  final List<Map<String, dynamic>> data;
  final int page;
  final bool hasReachedMax;
  final String searchQuery;

  const RequestDeleteUserListStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
    this.searchQuery = '',
  });

  @override
  List<Object> get props => [data, page, hasReachedMax, searchQuery];

  RequestDeleteUserListStateSuccess copyWith({
    List<Map<String, dynamic>>? data,
    int? page,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return RequestDeleteUserListStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RequestDeleteUserListStateFailure extends RequestDeleteUserListState {
  final String message;

  const RequestDeleteUserListStateFailure({required this.message});

  @override
  List<Object> get props => [message];
}
