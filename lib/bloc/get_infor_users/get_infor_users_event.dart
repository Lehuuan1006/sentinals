part of 'get_infor_users_bloc.dart';

abstract class GetUsersProfileEvent extends Equatable {
  const GetUsersProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileInfo extends GetUsersProfileEvent {
  final String userId; // ID của người dùng để lấy thông tin từ Firestore

  const GetProfileInfo({required this.userId}); // Sử dụng named parameter

  @override
  List<Object> get props => [userId];
}