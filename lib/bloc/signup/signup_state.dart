part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String userId;
  final String? message;

  const SignupSuccess(this.userId, {this.message});

  @override
  List<Object> get props => [userId, message ?? ''];
}

class SignupFailure extends SignupState {
  final String error;
  final String? errorDetails; 

  const SignupFailure(this.error, {this.errorDetails});

  @override
  List<Object> get props => [error, errorDetails ?? ''];
}