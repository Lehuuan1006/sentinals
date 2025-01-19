part of 'request_delete_user_bloc.dart';

abstract class RequestDeleteUserEvent extends Equatable {
  const RequestDeleteUserEvent();

  @override
  List<Object> get props => [];
}

class RequestDeleteUser extends RequestDeleteUserEvent {
  final String uid; // UID của người dùng
  final String email; // Email của người dùng

  const RequestDeleteUser({required this.uid, required this.email});

  @override
  List<Object> get props => [uid, email];
}