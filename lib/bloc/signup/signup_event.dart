part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupButtonPressed extends SignupEvent {
  final String email;
  final String password;
  final String contactName;
  final String phoneNumber;
  final String role;
  final String profileImage;

  const SignupButtonPressed({
    required this.email,
    required this.password,
    required this.contactName,
    required this.phoneNumber,
    required this.role,
    required this.profileImage,
  });

  @override
  List<Object> get props => [email, password, contactName, phoneNumber, role, profileImage];
}