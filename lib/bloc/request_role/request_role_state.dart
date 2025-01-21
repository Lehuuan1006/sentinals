part of 'request_role_bloc.dart';

abstract class RequestRoleState {}

class RequestRoleInitial extends RequestRoleState {}

class RequestRoleLoading extends RequestRoleState {}

class RequestRoleSuccess extends RequestRoleState {
  final String message;

  RequestRoleSuccess(this.message);
}

class RequestRoleFailure extends RequestRoleState {
  final String message;

  RequestRoleFailure(this.message);
}