part of 'get_infor_users_bloc.dart';

abstract class GetUsersProfileState extends Equatable {
  const GetUsersProfileState();

  @override
  List<Object> get props => [];
}

class GetUsersProfileInitial extends GetUsersProfileState {}

class GetUsersProfileLoading extends GetUsersProfileState {}

class GetUsersProfileSuccess extends GetUsersProfileState {
  final String contactName;
  final String email;
  final String phoneNumber;
  final String profileImage; // Chuỗi base64
  final String role;

  const GetUsersProfileSuccess({
    required this.contactName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.role,
  });

  @override
  List<Object> get props => [contactName, email, phoneNumber, profileImage, role];
}

class GetUsersProfileFailure extends GetUsersProfileState {
  final String error;

  const GetUsersProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}