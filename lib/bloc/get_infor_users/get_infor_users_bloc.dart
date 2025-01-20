import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'get_infor_users_event.dart';
part 'get_infor_users_state.dart';

class GetUsersProfileBloc
    extends Bloc<GetUsersProfileEvent, GetUsersProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GetUsersProfileBloc() : super(GetUsersProfileInitial()) {
    on<GetProfileInfo>(_onGetProfileInfo);
  }

  Future<void> _onGetProfileInfo(
    GetProfileInfo event,
    Emitter<GetUsersProfileState> emit,
  ) async {
    emit(GetUsersProfileLoading()); // Bắt đầu loading
    // log('Fetching profile for userId: ${event.userId}');

    try {
      // Lấy thông tin người dùng từ Firestore
      final userDoc =
          await _firestore.collection('users').doc(event.userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // log('User Data: $userData');

        // Phát ra trạng thái thành công
        emit(GetUsersProfileSuccess(
          contactName: userData['contactName'] as String? ?? '',
          email: userData['email'] as String? ?? '',
          phoneNumber: userData['phoneNumber'] as String? ?? '',
          profileImage: userData['profileImage'] as String? ?? '',
          role: userData['role'] as String? ?? '',
        ));
      } else {
        emit(GetUsersProfileFailure('Người dùng không tồn tại'));
        log('GetUsersProfileFailure 1: User document does not exist for userId: ${event.userId}');
      }
    } catch (e) {
      // Phát ra trạng thái thất bại nếu có lỗi
      emit(GetUsersProfileFailure('Lỗi khi lấy thông tin: $e'));
      log('GetUsersProfileFailure 2: $e');
    }
  }
}
