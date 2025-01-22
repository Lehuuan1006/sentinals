part of 'request_role_bloc.dart';

abstract class RequestRoleEvent {}

class RequestRole extends RequestRoleEvent {
  final String contactName;
  final String userId;
  final String email;
  final String roleRequested;

  RequestRole({
    required this.contactName,
    required this.userId,
    required this.email,
    required this.roleRequested,
  });
}