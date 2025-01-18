part of 'change_password_bloc.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();
  @override
  List<Object?> get props => [];
}

class HandleChangePasswordStateInitial extends ChangePasswordState {}

class HandleChangePasswordStateLoading extends ChangePasswordState {}

class HandleChangePasswordStateSuccess extends ChangePasswordState {
  final String message;

  const HandleChangePasswordStateSuccess({required this.message});

  HandleChangePasswordStateSuccess copyWith({String? message}) {
    return HandleChangePasswordStateSuccess(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}

class HandleChangePasswordStateFailure extends ChangePasswordState {
  final String message;

  const HandleChangePasswordStateFailure({required this.message});

  HandleChangePasswordStateFailure copyWith({String? message}) {
    return HandleChangePasswordStateFailure(message: message ?? this.message);
  }

  @override
  List<Object?> get props => [message];
}
