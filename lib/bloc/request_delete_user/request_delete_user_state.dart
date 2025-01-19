part of 'request_delete_user_bloc.dart';

abstract class RequestDeleteUserState extends Equatable {
  const RequestDeleteUserState();

  @override
  List<Object> get props => [];
}

class RequestDeleteUserInitial extends RequestDeleteUserState {}

class RequestDeleteUserLoading extends RequestDeleteUserState {}

class RequestDeleteUserSuccess extends RequestDeleteUserState {
  final String message;

  const RequestDeleteUserSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RequestDeleteUserFailure extends RequestDeleteUserState {
  final String message;

  const RequestDeleteUserFailure(this.message);

  @override
  List<Object> get props => [message];
}