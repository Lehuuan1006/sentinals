part of 'signin_bloc.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final String userId;
  final String userRole;

  const SignInSuccess({required this.userId, required this.userRole});

  @override
  List<Object> get props => [userId, userRole];
}

class SignInFailure extends SignInState {
  final String error;

  const SignInFailure(this.error);

  @override
  List<Object> get props => [error];
}
