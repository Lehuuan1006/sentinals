part of 'list_user_bloc.dart';

abstract class ListUserState {}

class ListUserStateInitial extends ListUserState {}

class ListUserStateLoading extends ListUserState {}

class ListUserStateSuccess extends ListUserState {
  final List<Map<String, dynamic>> data;
  final int page;
  final bool hasReachedMax;

  ListUserStateSuccess({
    required this.data,
    required this.page,
    required this.hasReachedMax,
  });

  ListUserStateSuccess copyWith({
    List<Map<String, dynamic>>? data,
    int? page,
    bool? hasReachedMax,
  }) {
    return ListUserStateSuccess(
      data: data ?? this.data,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ListUserStateFailure extends ListUserState {
  final String message;

  ListUserStateFailure({required this.message});
}