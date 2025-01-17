part of 'get_infor_profile_bloc.dart';

abstract class GetInforProfileState extends Equatable {
  const GetInforProfileState();

  @override
  List<Object> get props => [];
}

class GetInforProfileInitial extends GetInforProfileState {}

class GetInforProfileLoading extends GetInforProfileState {}

class GetInforProfileSuccess extends GetInforProfileState {
  final String contactName;
  final String email;
  final String phoneNumber;
  final String profileImage; // Chuỗi base64
  final String role;

  const GetInforProfileSuccess({
    required this.contactName,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.role,
  });

  @override
  List<Object> get props => [contactName, email, phoneNumber, profileImage, role];
}

class GetInforProfileFailure extends GetInforProfileState {
  final String error;

  const GetInforProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}