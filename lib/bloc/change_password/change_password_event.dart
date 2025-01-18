part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class HandleChangePassword extends ChangePasswordEvent {
  final String userID;
  final String oldPassword;
  final String newPassword;
  final String confirmNewPassword;

  const HandleChangePassword({
    required this.userID,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object> get props => [userID, oldPassword, newPassword, confirmNewPassword];
}