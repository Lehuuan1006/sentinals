part of 'update_infor_profile_bloc.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileInfo extends UpdateProfileEvent {
  final String userId;
  final String? contactName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final String? role;

  const UpdateProfileInfo({
    required this.userId,
    this.contactName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.role,
  });

  @override
  List<Object> get props => [userId];
}