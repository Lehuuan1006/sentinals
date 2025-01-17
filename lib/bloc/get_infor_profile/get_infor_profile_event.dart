part of 'get_infor_profile_bloc.dart';

abstract class GetInforProfileEvent extends Equatable {
  const GetInforProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileInfo extends GetInforProfileEvent {
  final String userId; // ID của người dùng để lấy thông tin từ Firestore

  const GetProfileInfo({required this.userId}); // Sử dụng named parameter

  @override
  List<Object> get props => [userId];
}